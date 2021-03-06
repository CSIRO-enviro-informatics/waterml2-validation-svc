<?xml version="1.0" encoding="UTF-8"?>
<schema fpi="http://schemas.opengis.net/waterml/2.0/waterObservation.sch" see="http://www.opengeospatial.org/projects/groups/waterml2.0swg"
  xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
        This Schematron schema checks that the timeseries type adheres to the requirements class
        http://www.opengis.net/spec/waterml/2.0/req/xsd-timeseries-time-value-pair. This is the time-value
        pair representation of timeseries. 
        
        WaterML 2.0 - XML
        Implementation is an OGC Standard Copyright (c) [2011] Open Geospatial Consortium, Inc.
        All Rights Reserved. To obtain additional rights of use, visit
        http://www.opengeospatial.org/legal/. 
    -->

  <title>WaterML2.0 timseries validation</title>
  <p>Verifies that the Timeseries type follows the requirements specified by 
    http://www.opengis.net/spec/waterml/2.0/req/xsd-timeseries-time-value-pair</p>
  <ns prefix="wml2" uri="http://www.opengis.net/waterml/2.0"/>
  <ns prefix="om" uri="http://www.opengis.net/om/2.0"/>
  <ns prefix="gml" uri="http://www.opengis.net/gml/3.2"/>
  <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
  <ns
    prefix="xlink"
    uri="http://www.w3.org/1999/xlink"/>

  <!-- Imports are required for schema-aware schematron rules (type checking) in tools. Will be updated to online schema --> 
  <xsl:import-schema schema-location="file:/Volumes/tay345/WaterML2.0_Specification/schema/handcrafted/waterml2.xsd"
  namespace="http://www.opengis.net/waterml/2.0"/>
  
  <xsl:import-schema schema-location="http://schemas.opengis.net/gml/3.2.1/gml.xsd"
    namespace="http://www.opengis.net/gml/3.2"/>

  <pattern id="datetime_check">
    <!-- Requirement is part of the xml encoding class but need to test specific time elements --> 
    <title>Tests /req/xsd-encoding-rules/iso8601-time and /req/xsd-encoding-rules/time-zone</title>
    <rule context="//wml2:point/wml2:TimeValuePairMeasure/wml2:time">
      <let name="dateInstance" value="text()"/>
      <let name="dateTimezoneValid"
        value="matches($dateInstance, '.*(Z|[+-][0-9][0-9]:[0-9][0-9])')"/>
      <assert test="($dateInstance) and ($dateTimezoneValid)" flag="error">
        Input value is
        <value-of select="$dateInstance"/>
        Timezone is mandatory according to the following format YYYY-MM-DDTHH:MM:SS(.s+)?(Z|[+-]HH:MM). TZ specifier must exist.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="equidistant_series">
    <title>Tests /req/xsd-timeseries-time-value-pair/equidistant-encoding 
      and /req/xsd-timeseries-time-value-pair/time-mandatory	</title>
    <rule context="//wml2:Timeseries/wml2:metadata/wml2:TSMetadata">
      <assert test="(wml2:spacing and wml2:baseTime) or (not(wml2:spacing) and not(wml2:baseTime))">
        Both spacing and baseTime need to be specifed if equidistant series, otherwise neither should be used. </assert>
    </rule>
    
    <!-- Checks that time is present if equidistant points are not being used. If baseTime and spacing are 
      used then time should not be present (might want to make this a warning - should it be possible to specify a time 
      to override the equidistant calculation? --> 
    <rule context="//wml2:Timeseries/wml2:point/wml2:TimeValuePairMeasure">
      <assert test="(wml2:time and not(../../wml2:metadata/wml2:TSMetadata/wml2:spacing)
        or (not(wml2:time) and (../../wml2:metadata/wml2:TSMetadata/wml2:spacing)))">
        The time for each point in the series must be specified if equidistant spacing isn't being used (i.e. you must
        specify the baseTime and spacing elements). If baseTime and spacing are specified then time is not required. 
      </assert>
    </rule>
  </pattern>

  <!-- All null values must provide a nilReason or a censoredReason --> 
  <pattern id="null_values">
    <title>Tests /req/xsd-timeseries-time-value-pair/null-point-reason</title>
    <rule context="//wml2:Timeseries/wml2:point/wml2:TimeValuePairMeasure/wml2:value[@xsi:nil]">
      <assert test="../wml2:metadata/wml2:TVPMetadata/wml2:nilReason or ../wml2:metadata/wml2:TVPMetadata/wml2:censoredReason">
        All null points must provide a nilReason. </assert>
    </rule>
  </pattern>
  
</schema>
