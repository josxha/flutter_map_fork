# Using Stadia Maps

{% hint style="info" %}
'flutter\_map' is in no way associated or related with Stadia Maps.

Stadia Maps' home page: [stadiamaps.com](https://stadiamaps.com/)\
Stadia Maps' pricing page: [stadiamaps.com/pricing](https://stadiamaps.com/pricing/)\
Stadia Maps' documentation page: [docs.stadiamaps.com](https://docs.stadiamaps.com/)
{% endhint %}

To integrate with 3rd party mapping libraries, Stadia Maps provides an alternative to the normal 'Static Maps Base URL' for each map style.

The 'Raster XYZ PNGs' URL contains all the information and placeholders that flutter\_map requires to display a map. Tiles requested through this endpoint consume the 'Styled Raster Map Tiles' credits.

Once you have the appropriate URL for your desired map style (see [#styles](using-stadia-maps.md#styles "mention")), use it in a `TileLayer`'s `urlTemplate` as normal.

Retina tiles (high-DPI) tiles are available. Use the URLs containing '@2x' instead of '{r}'. The maximum zoom level that Stadia Maps supports is 20, so it is recommended to set `maxNativeZoom` or `maxZoom` as such.

{% hint style="warning" %}
Attribution is required, see [docs.stadiamaps.com/#legal-details-required-attribution](https://docs.stadiamaps.com/#legal-details-required-attribution).

Consider using the [#richattributionwidget](../layers/attribution-layer.md#richattributionwidget "mention") or [#simpleattributionwidget](../layers/attribution-layer.md#simpleattributionwidget "mention")s, which meet the requirements.
{% endhint %}

## Styles

Stadia Maps offers a variety of ready-made map styles that don't require customization. URLs are found with the style: see the available [map styles](https://docs.stadiamaps.com/themes). The URL should be used as above.

## Vector Usage

Stadia Maps' also provides vector tiles. For more information about using vector tiles, please see [#using-vector-tiles](../explanation/raster-vs-vector-tiles.md#using-vector-tiles "mention").&#x20;

However, please note that this method of integration is still experimental. Many of the Stadia Maps styles utilize advanced features of the Mapbox GL JSON style language which are not yet well-supported.