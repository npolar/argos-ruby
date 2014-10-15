<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output omit-xml-declaration="yes" indent="yes"/>
 <xsl:strip-space elements="*"/>
<!--
  Transform Argos data XML to Tracking JSON (http://api.npolar.no/schema/tracking)

  Usage:
    xsltproc argos-xml-to-tracking-json.xslt argos.xml
    
    xsltproc argos-xml-to-tracking-json.xslt - -stringparam filename "argos-2014-06-11-platform-129654.xml" argos-2014-06-11-platform-129654.xml
    
    @todo param name system to force gps on known gps devices?
    @todo test with errors
    
-->
  <xsl:param name="filename" select="''"/>
  <xsl:param name="npolar" select="'true'"/>


<xsl:template match="/">  
[<xsl:for-each select="/data[number(@version) &lt; 2]/program/platform/satellitePass/message">
  
  <xsl:variable name="programNumber" select="ancestor::program/programNumber" />
  <xsl:variable name="platform" select="ancestor::program/platform" />
  <xsl:variable name="satellitePass" select="parent::satellitePass" />
  <xsl:variable name="location" select="$satellitePass/location" />
  
{ "program": "<xsl:value-of select="$programNumber"/>",
  "platform": "<xsl:value-of select="$platform/platformId"/>",
  "platform_type": "<xsl:value-of select="$platform/platformType"/>",
  "platform_model": "<xsl:value-of select="$platform/platformModel"/>",
  "platform_name": "<xsl:value-of select="$platform/platformName"/>",
  "platform_id": "<xsl:value-of select="$platform/platformHexId"/>",  
  "latitude": <xsl:choose><xsl:when test="number($location/latitude) = $location/latitude"><xsl:value-of select="$location/latitude"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "longitude": <xsl:choose><xsl:when test="number($location/longitude) = $location/longitude"><xsl:value-of select="$location/longitude"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "altitude": <xsl:choose><xsl:when test="number($location/altitude) = $location/altitude"><xsl:value-of select="$location/altitude"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "measured": "<xsl:value-of select="$satellitePass/bestMsgDate"/>",
  "satellite": "<xsl:value-of select="$satellitePass/satellite"/>",
  "duration": <xsl:value-of select="$satellitePass/duration"/>,
  "messages": <xsl:value-of select="$satellitePass/nbMessage"/>,
  "messages_120dB": <xsl:choose><xsl:when test="number($satellitePass/message120) = $satellitePass/message120"><xsl:value-of select="$satellitePass/message120"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "best_level": <xsl:choose><xsl:when test="number($satellitePass/bestLevel) = $satellitePass/bestLevel"><xsl:value-of select="$satellitePass/bestLevel"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "frequency": <xsl:choose><xsl:when test="number($satellitePass/frequency) = $satellitePass/frequency"><xsl:value-of select="$satellitePass/frequency"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>, 
  "positioned": <xsl:choose><xsl:when test="$location/locationDate != ''">"<xsl:value-of select="$location/locationDate"/>"</xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "lc": <xsl:choose><xsl:when test="$location/locationClass != ''">"<xsl:value-of select="$location/locationClass"/>"</xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,<xsl:choose><xsl:when test="$location/diagnostic">
  "lc_index": <xsl:choose><xsl:when test="number($location/diagnostic/index) = $location/diagnostic/index"><xsl:value-of select="$location/diagnostic/index"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "latitude2": <xsl:value-of select="$location/diagnostic/latitude2"/>,
  "longitude2": <xsl:value-of select="$location/diagnostic/longitude2"/>,
  "altitude2": <xsl:value-of select="$location/diagnostic/altitude2"/>,
  "nopc": <xsl:value-of select="$location/diagnostic/nopc"/>,
  "error_radius": <xsl:value-of select="$location/diagnostic/errorRadius"/>,
  "semi_major": <xsl:value-of select="$location/diagnostic/semiMajor"/>,
  "semi_minor": <xsl:value-of select="$location/diagnostic/semiMinor"/>,
  "speed": <xsl:choose><xsl:when test="number($location/diagnostic/gpsSpeed) = $location/diagnostic/gpsSpeed"><xsl:value-of select="$location/diagnostic/gpsSpeed"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "heading": <xsl:choose><xsl:when test="number($location/diagnostic/gpsHeading) = $location/diagnostic/gpsHeading"><xsl:value-of select="$location/diagnostic/gpsHeading"/></xsl:when><xsl:otherwise>null</xsl:otherwise></xsl:choose>,
  "orientation": <xsl:value-of select="$location/diagnostic/orientation"/>,
  "hdop": <xsl:value-of select="$location/diagnostic/hdop"/>,</xsl:when></xsl:choose>
  "row": <xsl:value-of select="position()"/>,
  "total": <xsl:value-of select="count(//message)"/>,
  "file": "<xsl:value-of select="$filename"/>",
  "identical": <xsl:value-of select="compression"/>,
  "sensor_data": [<xsl:for-each select="format/sensor/value">"<xsl:value-of select="."/>"<xsl:choose><xsl:when test="position() &lt; last()">,</xsl:when></xsl:choose></xsl:for-each>],
  "sensor_hex": "<xsl:value-of select="collect/rawData"/>",
  "sensor": [<xsl:for-each select="format/sensor">{"name": "<xsl:value-of select="name"/>", "value": "<xsl:value-of select="value|valueStr"/>", "value_type": "<xsl:value-of select="valueType"/>", "order": <xsl:value-of select="order"/> }<xsl:choose><xsl:when test="position() &lt; last()">, </xsl:when></xsl:choose></xsl:for-each>],
  "doppler": <xsl:value-of select="collect/doppler"/>,
  "level": <xsl:value-of select="collect/level"/>,
  "collects": <xsl:value-of select="count(collect)"/>,
  "formats": <xsl:value-of select="count(format)"/>,
  "collect": [<xsl:for-each select="collect">{ "level": <xsl:value-of select="level"/>, "type": "<xsl:value-of select="type"/>", "alarm": "<xsl:value-of select="alarm"/>", "concatenated": "<xsl:value-of select="concatenated"/>", "hex": "<xsl:value-of select="rawData"/>", "doppler": <xsl:value-of select="doppler"/>, "measured": "<xsl:value-of select="date"/>" }<xsl:choose><xsl:when test="position() &lt; last()">,</xsl:when></xsl:choose></xsl:for-each>],
  "format": [<xsl:for-each select="format">{ "order": <xsl:value-of select="formatOrder"/>, "name": "<xsl:value-of select="formatName"/>" }<xsl:choose><xsl:when test="position() &lt; last()">,</xsl:when></xsl:choose></xsl:for-each>]<xsl:choose><xsl:when test="$npolar = 'true'">,
  "schema": "http://api.npolar.no/schema/tracking",
  "collection": "tracking",
  "technology": "argos",
  "system": "<xsl:choose><xsl:when test="number($location/diagnostic/gpsSpeed) = $location/diagnostic/gpsSpeed">gps</xsl:when><xsl:otherwise>argos</xsl:otherwise></xsl:choose>",
  "parser": "argos-xml-to-tracking-json.xslt",
  "type": "xml"</xsl:when></xsl:choose><xsl:choose><xsl:when test="count(/data/errors/error) &gt; 0">,
  "warn": [<xsl:for-each select="/data/errors/error">"<xsl:value-of select="."/> (argos webservice error code <xsl:value-of select="@code"/>)"<xsl:choose><xsl:when test="position() &lt; last()">,</xsl:when></xsl:choose></xsl:for-each>]</xsl:when></xsl:choose>}<xsl:choose><xsl:when test="position() &lt; last()">,</xsl:when></xsl:choose>
</xsl:for-each>]
</xsl:template>

</xsl:stylesheet>