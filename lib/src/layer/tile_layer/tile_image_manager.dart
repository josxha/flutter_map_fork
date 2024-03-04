import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_bounds/tile_bounds.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_bounds/tile_bounds_at_zoom.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_image_view.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range.dart';
import 'package:meta/meta.dart';

/// Callback definition to crete a [TileImage] for [TileCoordinates].
typedef TileCreator = TileImage Function(TileCoordinates coordinates);

/// The [TileImageManager] orchestrates the loading and pruning of tiles.
@immutable
class TileImageManager {
  /// Filter tiles to only tiles that would be visible on screen. Specifically:
  ///   1. Tiles in the visible range at the target zoom level.
  ///   2. Tiles at non-target zoom level that would cover up holes that would
  ///      be left by tiles in #1, which are not ready yet.
  Iterable<TileImage> getTilesToRender({
    required ,
  }) =>
      TileImageView(
        tileImages: _tiles,
        visibleRange: visibleRange,
        // `keepRange` is irrelevant here since we're not using the output for
        // pruning storage but rather to decide on what to put on screen.
        keepRange: visibleRange,
      ).renderTiles;



  /// Creates missing [TileImage]s within the provided tile range. Returns a
  /// list of [TileImage]s which haven't started loading yet.
  List<TileImage> createMissingTiles(
    DiscreteTileRange tileRange,
    TileBoundsAtZoom tileBoundsAtZoom, {
    required TileCreator createTile,
  }) {
    final notLoaded = <TileImage>[];

    for (final coordinates in tileBoundsAtZoom.validCoordinatesIn(tileRange)) {
      final tile = _tiles[coordinates] ??= createTile(coordinates);
      if (tile.loadStarted == null) {
        notLoaded.add(tile);
      }
    }

    return notLoaded;
  }

  /// Set the new [TileDisplay] for all [_tiles].
  void updateTileDisplay(TileDisplay tileDisplay) {
    for (final tile in _tiles.values) {
      tile.tileDisplay = tileDisplay;
    }
  }

  /// All removals should be performed by calling this method to ensure that
  /// disposal is performed correctly.
  void _remove(
    TileCoordinates key, {
    required bool Function(TileImage tileImage) evictImageFromCache,
  }) {
    final removed = _tiles.remove(key);

    if (removed != null) {
      removed.dispose(evictImageFromCache: evictImageFromCache(removed));
    }
  }

  void _removeWithEvictionStrategy(
    TileCoordinates key,
    EvictErrorTileStrategy strategy,
  ) {
    _remove(
      key,
      evictImageFromCache: (tileImage) =>
          tileImage.loadError && strategy != EvictErrorTileStrategy.none,
    );
  }

  /// Remove all tiles with a given [EvictErrorTileStrategy].
  void removeAll(EvictErrorTileStrategy evictStrategy) {
    final keysToRemove = List<TileCoordinates>.from(_tiles.keys);

    for (final key in keysToRemove) {
      _removeWithEvictionStrategy(key, evictStrategy);
    }
  }

  /// Reload all tile images of a [TileLayer] for a given tile bounds.
  void reloadImages(
    TileLayer layer,
    TileBounds tileBounds,
  ) {
    // If a TileImage's imageInfo is already available when load() is called it
    // will call its onLoadComplete callback synchronously which can trigger
    // pruning. Since pruning may cause removals from _tiles we must not
    // iterate _tiles directly otherwise a concurrent modification error may
    // occur. To avoid this we create a copy of the collection of tiles to
    // reload and iterate over that instead.
    final tilesToReload = List<TileImage>.from(_tiles.values);

    for (final tile in tilesToReload) {
      tile.imageProvider = layer.tileProvider.supportsCancelLoading
          ? layer.tileProvider.getImageWithCancelLoadingSupport(
              tileBounds.atZoom(tile.coordinates.z).wrap(tile.coordinates),
              layer,
              tile.cancelLoading.future,
            )
          : layer.tileProvider.getImage(
              tileBounds.atZoom(tile.coordinates.z).wrap(tile.coordinates),
              layer,
            );
      tile.load();
    }
  }

  /// evict tiles that have an error and prune tiles that are no longer needed.
  void evictAndPrune({
    required DiscreteTileRange visibleRange,
    required int pruneBuffer,
    required EvictErrorTileStrategy evictStrategy,
  }) {
    final pruningState = TileImageView(
      tileImages: _tiles,
      visibleRange: visibleRange,
      keepRange: visibleRange.expand(pruneBuffer),
    );

    _evictErrorTiles(pruningState, evictStrategy);
    _prune(pruningState, evictStrategy);
  }

  void _evictErrorTiles(
    TileImageView tileRemovalState,
    EvictErrorTileStrategy evictStrategy,
  ) {
    switch (evictStrategy) {
      case EvictErrorTileStrategy.notVisibleRespectMargin:
        for (final tileImage
            in tileRemovalState.errorTilesOutsideOfKeepMargin()) {
          _remove(tileImage.coordinates, evictImageFromCache: (_) => true);
        }
      case EvictErrorTileStrategy.notVisible:
        for (final tileImage in tileRemovalState.errorTilesNotVisible()) {
          _remove(tileImage.coordinates, evictImageFromCache: (_) => true);
        }
      case EvictErrorTileStrategy.dispose:
      case EvictErrorTileStrategy.none:
        return;
    }
  }

  /// Prune tiles from the [TileImageManager].
  void prune({
    required DiscreteTileRange visibleRange,
    required int pruneBuffer,
    required EvictErrorTileStrategy evictStrategy,
  }) {
    _prune(
      TileImageView(
        tileImages: _tiles,
        visibleRange: visibleRange,
        keepRange: visibleRange.expand(pruneBuffer),
      ),
      evictStrategy,
    );
  }

  /// Prune tiles from the [TileImageManager].
  void _prune(
    TileImageView tileRemovalState,
    EvictErrorTileStrategy evictStrategy,
  ) {
    for (final tileImage in tileRemovalState.staleTiles) {
      _removeWithEvictionStrategy(tileImage.coordinates, evictStrategy);
    }
  }
}
