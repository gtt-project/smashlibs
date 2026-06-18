<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml" xmlns="http://www.opengis.net/sld" version="1.0.0">
  <sld:UserLayer>
    <sld:UserStyle>
      <sld:Name>style</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Name>fts</sld:Name>
        <sld:Rule>
          <sld:Name>rule</sld:Name>
          <sld:PointSymbolizer>
            <sld:Graphic>
              <sld:Size>5.0</sld:Size>
              <sld:Mark>
                <sld:WellKnownName>circle</sld:WellKnownName>
                <sld:Fill>
                  <sld:CssParameter name="fill">#000000</sld:CssParameter>
                  <sld:CssParameter name="fill-opacity">1.0</sld:CssParameter>
                </sld:Fill>
                <sld:Stroke>
                  <sld:CssParameter name="stroke">#000000</sld:CssParameter>
                  <sld:CssParameter name="stroke-opacity">1.0</sld:CssParameter>
                  <sld:CssParameter name="stroke-width">1.0</sld:CssParameter>
                </sld:Stroke>
              </sld:Mark>
            </sld:Graphic>
          </sld:PointSymbolizer>
          <sld:LineSymbolizer>
            <sld:Stroke>
              <sld:CssParameter name="stroke">#000000</sld:CssParameter>
              <sld:CssParameter name="stroke-opacity">1.0</sld:CssParameter>
              <sld:CssParameter name="stroke-width">4.0</sld:CssParameter>
            </sld:Stroke>
          </sld:LineSymbolizer>
          <sld:TextSymbolizer>
            <sld:Label>
              <ogc:PropertyName></ogc:PropertyName>
            </sld:Label>
            <sld:Font>
              <sld:CssParameter name="font-size">12.0</sld:CssParameter>
            </sld:Font>
            <sld:Fill>
              <sld:CssParameter name="fill">#000000</sld:CssParameter>
            </sld:Fill>
            <sld:Halo>
              <sld:Radius>1.0</sld:Radius>
              <sld:Fill>
                <sld:CssParameter name="fill">#FFFFFF</sld:CssParameter>
              </sld:Fill>
            </sld:Halo>
          </sld:TextSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </sld:UserLayer>
</StyledLayerDescriptor>