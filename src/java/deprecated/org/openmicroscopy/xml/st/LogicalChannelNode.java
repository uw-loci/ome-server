/*
 * org.openmicroscopy.xml.LogicalChannelNode
 *
 *-----------------------------------------------------------------------------
 *
 *  Copyright (C) 2007 Open Microscopy Environment
 *      Massachusetts Institute of Technology,
 *      National Institutes of Health,
 *      University of Dundee,
 *      University of Wisconsin-Madison
 *
 *
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *-----------------------------------------------------------------------------
 */


/*-----------------------------------------------------------------------------
 *
 * THIS IS AUTOMATICALLY GENERATED CODE.  DO NOT MODIFY.
 * Created by curtis via Xmlgen on Dec 18, 2007 12:41:44 PM CST
 *
 *-----------------------------------------------------------------------------
 */

package org.openmicroscopy.xml.st;

import java.util.List;
import ome.xml.OMEXMLNode;
import org.openmicroscopy.xml.*;
import org.openmicroscopy.ds.st.*;
import org.w3c.dom.Element;

/**
 * LogicalChannelNode is the node corresponding to the
 * "LogicalChannel" XML element.
 *
 * Name: LogicalChannel
 * AppliesTo: I
 * Location: OME/src/xml/OME/Core/Image.ome
 * Description: Varias piezas de informacion pertenecientes a cada canal logico
 *   en una imagen
 */
public class LogicalChannelNode extends AttributeNode
  implements LogicalChannel
{

  // -- Constructors --

  /**
   * Constructs a LogicalChannel node
   * with the given associated DOM element.
   */
  public LogicalChannelNode(Element element) { super(element); }

  /**
   * Constructs a LogicalChannel node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public LogicalChannelNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a LogicalChannel node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public LogicalChannelNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "LogicalChannel", attach);
  }

  /**
   * Constructs a LogicalChannel node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public LogicalChannelNode(CustomAttributesNode parent, String name,
    Integer samplesPerPixel, Filter filter, LightSource lightSource,
    Float lightAttenuation, Integer lightWavelength, OTF otf,
    Detector detector, Float detectorOffset, Float detectorGain,
    String illuminationType, Integer pinholeSize,
    String photometricInterpretation, String mode, String contrastMethod,
    LightSource auxLightSource, Float auxLightAttenuation,
    String auxTechnique, Integer auxLightWavelength,
    Integer excitationWavelength, Integer emissionWavelength, String fluor,
    Float ndfilter)
  {
    this(parent, true);
    setName(name);
    setSamplesPerPixel(samplesPerPixel);
    setFilter(filter);
    setLightSource(lightSource);
    setLightAttenuation(lightAttenuation);
    setLightWavelength(lightWavelength);
    setOTF(otf);
    setDetector(detector);
    setDetectorOffset(detectorOffset);
    setDetectorGain(detectorGain);
    setIlluminationType(illuminationType);
    setPinholeSize(pinholeSize);
    setPhotometricInterpretation(photometricInterpretation);
    setMode(mode);
    setContrastMethod(contrastMethod);
    setAuxLightSource(auxLightSource);
    setAuxLightAttenuation(auxLightAttenuation);
    setAuxTechnique(auxTechnique);
    setAuxLightWavelength(auxLightWavelength);
    setExcitationWavelength(excitationWavelength);
    setEmissionWavelength(emissionWavelength);
    setFluor(fluor);
    setNDFilter(ndfilter);
  }


  // -- LogicalChannel API methods --

  /**
   * Gets Name attribute
   * of the LogicalChannel element.
   */
  public String getName() {
    return getAttribute("Name");
  }

  /**
   * Sets Name attribute
   * for the LogicalChannel element.
   */
  public void setName(String value) {
    setAttribute("Name", value);  }

  /**
   * Gets SamplesPerPixel attribute
   * of the LogicalChannel element.
   */
  public Integer getSamplesPerPixel() {
    return getIntegerAttribute("SamplesPerPixel");
  }

  /**
   * Sets SamplesPerPixel attribute
   * for the LogicalChannel element.
   */
  public void setSamplesPerPixel(Integer value) {
    setAttribute("SamplesPerPixel", value);  }

  /**
   * Gets Filter referenced by Filter
   * attribute of the LogicalChannel element.
   */
  public Filter getFilter() {
    return (Filter)
      getAttrReferencedNode("Filter", "Filter");
  }

  /**
   * Sets Filter referenced by Filter
   * attribute of the LogicalChannel element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of FilterNode
   */
  public void setFilter(Filter value) {
    setAttrReferencedNode((OMEXMLNode) value, "Filter");
  }

  /**
   * Gets LightSource referenced by LightSource
   * attribute of the LogicalChannel element.
   */
  public LightSource getLightSource() {
    return (LightSource)
      getAttrReferencedNode("LightSource", "LightSource");
  }

  /**
   * Sets LightSource referenced by LightSource
   * attribute of the LogicalChannel element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of LightSourceNode
   */
  public void setLightSource(LightSource value) {
    setAttrReferencedNode((OMEXMLNode) value, "LightSource");
  }

  /**
   * Gets LightAttenuation attribute
   * of the LogicalChannel element.
   */
  public Float getLightAttenuation() {
    return getFloatAttribute("LightAttenuation");
  }

  /**
   * Sets LightAttenuation attribute
   * for the LogicalChannel element.
   */
  public void setLightAttenuation(Float value) {
    setAttribute("LightAttenuation", value);  }

  /**
   * Gets LightWavelength attribute
   * of the LogicalChannel element.
   */
  public Integer getLightWavelength() {
    return getIntegerAttribute("LightWavelength");
  }

  /**
   * Sets LightWavelength attribute
   * for the LogicalChannel element.
   */
  public void setLightWavelength(Integer value) {
    setAttribute("LightWavelength", value);  }

  /**
   * Gets OTF referenced by OTF
   * attribute of the LogicalChannel element.
   */
  public OTF getOTF() {
    return (OTF)
      getAttrReferencedNode("OTF", "OTF");
  }

  /**
   * Sets OTF referenced by OTF
   * attribute of the LogicalChannel element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of OTFNode
   */
  public void setOTF(OTF value) {
    setAttrReferencedNode((OMEXMLNode) value, "OTF");
  }

  /**
   * Gets Detector referenced by Detector
   * attribute of the LogicalChannel element.
   */
  public Detector getDetector() {
    return (Detector)
      getAttrReferencedNode("Detector", "Detector");
  }

  /**
   * Sets Detector referenced by Detector
   * attribute of the LogicalChannel element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of DetectorNode
   */
  public void setDetector(Detector value) {
    setAttrReferencedNode((OMEXMLNode) value, "Detector");
  }

  /**
   * Gets DetectorOffset attribute
   * of the LogicalChannel element.
   */
  public Float getDetectorOffset() {
    return getFloatAttribute("DetectorOffset");
  }

  /**
   * Sets DetectorOffset attribute
   * for the LogicalChannel element.
   */
  public void setDetectorOffset(Float value) {
    setAttribute("DetectorOffset", value);  }

  /**
   * Gets DetectorGain attribute
   * of the LogicalChannel element.
   */
  public Float getDetectorGain() {
    return getFloatAttribute("DetectorGain");
  }

  /**
   * Sets DetectorGain attribute
   * for the LogicalChannel element.
   */
  public void setDetectorGain(Float value) {
    setAttribute("DetectorGain", value);  }

  /**
   * Gets IlluminationType attribute
   * of the LogicalChannel element.
   */
  public String getIlluminationType() {
    return getAttribute("IlluminationType");
  }

  /**
   * Sets IlluminationType attribute
   * for the LogicalChannel element.
   */
  public void setIlluminationType(String value) {
    setAttribute("IlluminationType", value);  }

  /**
   * Gets PinholeSize attribute
   * of the LogicalChannel element.
   */
  public Integer getPinholeSize() {
    return getIntegerAttribute("PinholeSize");
  }

  /**
   * Sets PinholeSize attribute
   * for the LogicalChannel element.
   */
  public void setPinholeSize(Integer value) {
    setAttribute("PinholeSize", value);  }

  /**
   * Gets PhotometricInterpretation attribute
   * of the LogicalChannel element.
   */
  public String getPhotometricInterpretation() {
    return getAttribute("PhotometricInterpretation");
  }

  /**
   * Sets PhotometricInterpretation attribute
   * for the LogicalChannel element.
   */
  public void setPhotometricInterpretation(String value) {
    setAttribute("PhotometricInterpretation", value);  }

  /**
   * Gets Mode attribute
   * of the LogicalChannel element.
   */
  public String getMode() {
    return getAttribute("Mode");
  }

  /**
   * Sets Mode attribute
   * for the LogicalChannel element.
   */
  public void setMode(String value) {
    setAttribute("Mode", value);  }

  /**
   * Gets ContrastMethod attribute
   * of the LogicalChannel element.
   */
  public String getContrastMethod() {
    return getAttribute("ContrastMethod");
  }

  /**
   * Sets ContrastMethod attribute
   * for the LogicalChannel element.
   */
  public void setContrastMethod(String value) {
    setAttribute("ContrastMethod", value);  }

  /**
   * Gets AuxLightSource referenced by LightSource
   * attribute of the LogicalChannel element.
   */
  public LightSource getAuxLightSource() {
    return (LightSource)
      getAttrReferencedNode("LightSource", "AuxLightSource");
  }

  /**
   * Sets AuxLightSource referenced by LightSource
   * attribute of the LogicalChannel element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of LightSourceNode
   */
  public void setAuxLightSource(LightSource value) {
    setAttrReferencedNode((OMEXMLNode) value, "AuxLightSource");
  }

  /**
   * Gets AuxLightAttenuation attribute
   * of the LogicalChannel element.
   */
  public Float getAuxLightAttenuation() {
    return getFloatAttribute("AuxLightAttenuation");
  }

  /**
   * Sets AuxLightAttenuation attribute
   * for the LogicalChannel element.
   */
  public void setAuxLightAttenuation(Float value) {
    setAttribute("AuxLightAttenuation", value);  }

  /**
   * Gets AuxTechnique attribute
   * of the LogicalChannel element.
   */
  public String getAuxTechnique() {
    return getAttribute("AuxTechnique");
  }

  /**
   * Sets AuxTechnique attribute
   * for the LogicalChannel element.
   */
  public void setAuxTechnique(String value) {
    setAttribute("AuxTechnique", value);  }

  /**
   * Gets AuxLightWavelength attribute
   * of the LogicalChannel element.
   */
  public Integer getAuxLightWavelength() {
    return getIntegerAttribute("AuxLightWavelength");
  }

  /**
   * Sets AuxLightWavelength attribute
   * for the LogicalChannel element.
   */
  public void setAuxLightWavelength(Integer value) {
    setAttribute("AuxLightWavelength", value);  }

  /**
   * Gets ExcitationWavelength attribute
   * of the LogicalChannel element.
   */
  public Integer getExcitationWavelength() {
    return getIntegerAttribute("ExcitationWavelength");
  }

  /**
   * Sets ExcitationWavelength attribute
   * for the LogicalChannel element.
   */
  public void setExcitationWavelength(Integer value) {
    setAttribute("ExcitationWavelength", value);  }

  /**
   * Gets EmissionWavelength attribute
   * of the LogicalChannel element.
   */
  public Integer getEmissionWavelength() {
    return getIntegerAttribute("EmissionWavelength");
  }

  /**
   * Sets EmissionWavelength attribute
   * for the LogicalChannel element.
   */
  public void setEmissionWavelength(Integer value) {
    setAttribute("EmissionWavelength", value);  }

  /**
   * Gets Fluor attribute
   * of the LogicalChannel element.
   */
  public String getFluor() {
    return getAttribute("Fluor");
  }

  /**
   * Sets Fluor attribute
   * for the LogicalChannel element.
   */
  public void setFluor(String value) {
    setAttribute("Fluor", value);  }

  /**
   * Gets NDFilter attribute
   * of the LogicalChannel element.
   */
  public Float getNDFilter() {
    return getFloatAttribute("NDFilter");
  }

  /**
   * Sets NDFilter attribute
   * for the LogicalChannel element.
   */
  public void setNDFilter(Float value) {
    setAttribute("NDFilter", value);  }

  /**
   * Gets a list of PixelChannelComponent elements
   * referencing this LogicalChannel node.
   */
  public List getPixelChannelComponentList() {
    return getAttrReferringNodes("PixelChannelComponent", "LogicalChannel");
  }

  /**
   * Gets the number of PixelChannelComponent elements
   * referencing this LogicalChannel node.
   */
  public int countPixelChannelComponentList() {
    return getAttrReferringCount("PixelChannelComponent", "LogicalChannel");
  }

}
