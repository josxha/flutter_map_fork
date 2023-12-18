import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/inherited_model.dart';
import 'package:latlong2/latlong.dart';

@immutable
class MapOptions {
  /// The Coordinate Reference System, defaults to [Epsg3857].
  final Crs crs;

  /// The center when the map is first loaded. If [initialCameraFit] is defined
  /// this has no effect.
  final LatLng initialCenter;

  /// The zoom when the map is first loaded. If [initialCameraFit] is defined
  /// this has no effect.
  final double initialZoom;

  /// The rotation when the map is first loaded.
  final double initialRotation;

  /// Defines the visible bounds when the map is first loaded. Takes precedence
  /// over [initialCenter]/[initialZoom].
  final CameraFit? initialCameraFit;

  final double? minZoom;
  final double? maxZoom;

  final Color backgroundColor;

  final TapCallback? onTap;
  final LongPressCallback? onLongPress;
  final TapCallback? onSecondaryTap;
  final LongPressCallback? onSecondaryLongPress;
  final TapCallback? onTertiaryTap;
  final LongPressCallback? onTertiaryLongPress;

  final void Function(PointerDownEvent event, LatLng point)? onPointerDown;
  final void Function(PointerUpEvent event, LatLng point)? onPointerUp;
  final void Function(PointerCancelEvent event, LatLng point)? onPointerCancel;
  final void Function(PointerHoverEvent event, LatLng point)? onPointerHover;

  final PositionCallback? onPositionChanged;

  final void Function(MapEvent event)? onMapEvent;

  /// Define limits for viewing the map.
  final CameraConstraint cameraConstraint;

  /// OnMapReady is called after the map runs it's initState.
  /// At that point the map has assigned its state to the controller
  /// Only use this if your map isn't built immediately (like inside FutureBuilder)
  /// and you need to access the controller as soon as the map is built.
  /// Otherwise you can use WidgetsBinding.instance.addPostFrameCallback
  /// In initState to control the map before the next frame.
  final VoidCallback? onMapReady;

  /// Flag to enable the built in keep alive functionality
  ///
  /// If the map is within a complex layout, such as a [ListView] or [PageView],
  /// the map will reset to it's initial position after it appears back into view.
  /// To ensure this doesn't happen, enable this flag to prevent the [FlutterMap]
  /// widget from rebuilding.
  final bool keepAlive;

  /// Whether to apply pointer translucency to all layers automatically
  ///
  /// This will mean that each layer can handle all the gestures that enter the
  /// map themselves. Without this, only the top layer may handle gestures.
  ///
  /// Note that layers that are visually obscured behind another layer will
  /// receive events, if this is enabled.
  ///
  /// Technically, layers become invisible to the parent `Stack` when hit
  /// testing (and thus `Stack` will keep bubbling gestures down all layers), but
  /// will still allow their subtree to receive pointer events.
  ///
  /// If this is `false` (defaults to `true`), then [TranslucentPointer] may be
  /// manually applied to individual layers.
  final bool applyPointerTranslucencyToLayers;

  final InteractionOptions interactionOptions;

  const MapOptions({
    this.crs = const Epsg3857(),
    this.initialCenter = const LatLng(50.5, 30.51),
    this.initialZoom = 13.0,
    this.initialRotation = 0.0,
    this.initialCameraFit,
    this.cameraConstraint = const CameraConstraint.unconstrained(),
    this.interactionOptions = const InteractionOptions(),
    this.minZoom,
    this.maxZoom,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryLongPress,
    this.onTertiaryTap,
    this.onTertiaryLongPress,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.onPointerHover,
    this.onPositionChanged,
    this.onMapEvent,
    this.onMapReady,
    this.keepAlive = false,
    this.applyPointerTranslucencyToLayers = true,
  });

  /// The options of the closest [FlutterMap] ancestor. If this is called from a
  /// context with no [FlutterMap] ancestor, null is returned.
  static MapOptions? maybeOf(BuildContext context) =>
      MapInheritedModel.maybeOptionsOf(context);

  /// The options of the closest [FlutterMap] ancestor. If this is called from a
  /// context with no [FlutterMap] ancestor a [StateError] will be thrown.
  static MapOptions of(BuildContext context) =>
      maybeOf(context) ??
      (throw StateError(
          '`MapOptions.of()` should not be called outside a `FlutterMap` and its descendants'));

  @override
  bool operator ==(Object other) =>
      other is MapOptions &&
      crs == other.crs &&
      initialCenter == other.initialCenter &&
      initialZoom == other.initialZoom &&
      initialRotation == other.initialRotation &&
      initialCameraFit == other.initialCameraFit &&
      minZoom == other.minZoom &&
      maxZoom == other.maxZoom &&
      backgroundColor == other.backgroundColor &&
      onTap == other.onTap &&
      onSecondaryTap == other.onSecondaryTap &&
      onLongPress == other.onLongPress &&
      onPointerDown == other.onPointerDown &&
      onPointerUp == other.onPointerUp &&
      onPointerCancel == other.onPointerCancel &&
      onPointerHover == other.onPointerHover &&
      onPositionChanged == other.onPositionChanged &&
      onMapEvent == other.onMapEvent &&
      cameraConstraint == other.cameraConstraint &&
      onMapReady == other.onMapReady &&
      keepAlive == other.keepAlive &&
      interactionOptions == other.interactionOptions &&
      backgroundColor == other.backgroundColor &&
      applyPointerTranslucencyToLayers ==
          other.applyPointerTranslucencyToLayers;

  @override
  int get hashCode => Object.hashAll([
        crs,
        initialCenter,
        initialZoom,
        initialRotation,
        initialCameraFit,
        minZoom,
        maxZoom,
        backgroundColor,
        onTap,
        onSecondaryTap,
        onLongPress,
        onPointerDown,
        onPointerUp,
        onPointerCancel,
        onPointerHover,
        onPositionChanged,
        onMapEvent,
        cameraConstraint,
        onMapReady,
        keepAlive,
        interactionOptions,
        backgroundColor,
        applyPointerTranslucencyToLayers,
      ]);
}

typedef TapCallback = void Function(TapDownDetails details, LatLng point);
typedef LongPressCallback = void Function(
  LongPressStartDetails details,
  LatLng point,
);