/*
 * org.openmicroscopy.xml.RenderingSettingsNode
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

import ome.xml.OMEXMLNode;
import org.openmicroscopy.xml.*;
import org.openmicroscopy.ds.st.*;
import org.w3c.dom.Element;

/**
 * RenderingSettingsNode is the node corresponding to the
 * "RenderingSettings" XML element.
 *
 * Name: RenderingSettings
 * AppliesTo: I
 * Location: OME/src/xml/OME/RenderingSettings.ome
 * Description: TEMPORARY FILE; NOT WELL WRITTEN! SHOULD BE REMOVED AS SOON AS
 *   THE NEW RENDERING CODE IS IMPLEMENTED.
 */
public class RenderingSettingsNode extends AttributeNode
  implements RenderingSettings
{

  // -- Constructors --

  /**
   * Constructs a RenderingSettings node
   * with the given associated DOM element.
   */
  public RenderingSettingsNode(Element element) { super(element); }

  /**
   * Constructs a RenderingSettings node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public RenderingSettingsNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a RenderingSettings node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public RenderingSettingsNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "RenderingSettings", attach);
  }

  /**
   * Constructs a RenderingSettings node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public RenderingSettingsNode(CustomAttributesNode parent,
    Experimenter experimenter, Integer theZ, Integer theT, Integer model,
    Integer family, Double coefficient, Integer cdStart, Integer cdEnd,
    Integer bitResolution, Integer theC, Double inputStart, Double inputEnd,
    Integer red, Integer green, Integer blue, Integer alpha, Boolean active)
  {
    this(parent, true);
    setExperimenter(experimenter);
    setTheZ(theZ);
    setTheT(theT);
    setModel(model);
    setFamily(family);
    setCoefficient(coefficient);
    setCdStart(cdStart);
    setCdEnd(cdEnd);
    setBitResolution(bitResolution);
    setTheC(theC);
    setInputStart(inputStart);
    setInputEnd(inputEnd);
    setRed(red);
    setGreen(green);
    setBlue(blue);
    setAlpha(alpha);
    setActive(active);
  }


  // -- RenderingSettings API methods --

  /**
   * Gets Experimenter referenced by Experimenter
   * attribute of the RenderingSettings element.
   */
  public Experimenter getExperimenter() {
    return (Experimenter)
      getAttrReferencedNode("Experimenter", "Experimenter");
  }

  /**
   * Sets Experimenter referenced by Experimenter
   * attribute of the RenderingSettings element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of ExperimenterNode
   */
  public void setExperimenter(Experimenter value) {
    setAttrReferencedNode((OMEXMLNode) value, "Experimenter");
  }

  /**
   * Gets TheZ attribute
   * of the RenderingSettings element.
   */
  public Integer getTheZ() {
    return getIntegerAttribute("TheZ");
  }

  /**
   * Sets TheZ attribute
   * for the RenderingSettings element.
   */
  public void setTheZ(Integer value) {
    setAttribute("TheZ", value);  }

  /**
   * Gets TheT attribute
   * of the RenderingSettings element.
   */
  public Integer getTheT() {
    return getIntegerAttribute("TheT");
  }

  /**
   * Sets TheT attribute
   * for the RenderingSettings element.
   */
  public void setTheT(Integer value) {
    setAttribute("TheT", value);  }

  /**
   * Gets Model attribute
   * of the RenderingSettings element.
   */
  public Integer getModel() {
    return getIntegerAttribute("Model");
  }

  /**
   * Sets Model attribute
   * for the RenderingSettings element.
   */
  public void setModel(Integer value) {
    setAttribute("Model", value);  }

  /**
   * Gets Family attribute
   * of the RenderingSettings element.
   */
  public Integer getFamily() {
    return getIntegerAttribute("Family");
  }

  /**
   * Sets Family attribute
   * for the RenderingSettings element.
   */
  public void setFamily(Integer value) {
    setAttribute("Family", value);  }

  /**
   * Gets Coefficient attribute
   * of the RenderingSettings element.
   */
  public Double getCoefficient() {
    return getDoubleAttribute("Coefficient");
  }

  /**
   * Sets Coefficient attribute
   * for the RenderingSettings element.
   */
  public void setCoefficient(Double value) {
    setAttribute("Coefficient", value);  }

  /**
   * Gets CdStart attribute
   * of the RenderingSettings element.
   */
  public Integer getCdStart() {
    return getIntegerAttribute("CdStart");
  }

  /**
   * Sets CdStart attribute
   * for the RenderingSettings element.
   */
  public void setCdStart(Integer value) {
    setAttribute("CdStart", value);  }

  /**
   * Gets CdEnd attribute
   * of the RenderingSettings element.
   */
  public Integer getCdEnd() {
    return getIntegerAttribute("CdEnd");
  }

  /**
   * Sets CdEnd attribute
   * for the RenderingSettings element.
   */
  public void setCdEnd(Integer value) {
    setAttribute("CdEnd", value);  }

  /**
   * Gets BitResolution attribute
   * of the RenderingSettings element.
   */
  public Integer getBitResolution() {
    return getIntegerAttribute("BitResolution");
  }

  /**
   * Sets BitResolution attribute
   * for the RenderingSettings element.
   */
  public void setBitResolution(Integer value) {
    setAttribute("BitResolution", value);  }

  /**
   * Gets TheC attribute
   * of the RenderingSettings element.
   */
  public Integer getTheC() {
    return getIntegerAttribute("TheC");
  }

  /**
   * Sets TheC attribute
   * for the RenderingSettings element.
   */
  public void setTheC(Integer value) {
    setAttribute("TheC", value);  }

  /**
   * Gets InputStart attribute
   * of the RenderingSettings element.
   */
  public Double getInputStart() {
    return getDoubleAttribute("InputStart");
  }

  /**
   * Sets InputStart attribute
   * for the RenderingSettings element.
   */
  public void setInputStart(Double value) {
    setAttribute("InputStart", value);  }

  /**
   * Gets InputEnd attribute
   * of the RenderingSettings element.
   */
  public Double getInputEnd() {
    return getDoubleAttribute("InputEnd");
  }

  /**
   * Sets InputEnd attribute
   * for the RenderingSettings element.
   */
  public void setInputEnd(Double value) {
    setAttribute("InputEnd", value);  }

  /**
   * Gets Red attribute
   * of the RenderingSettings element.
   */
  public Integer getRed() {
    return getIntegerAttribute("Red");
  }

  /**
   * Sets Red attribute
   * for the RenderingSettings element.
   */
  public void setRed(Integer value) {
    setAttribute("Red", value);  }

  /**
   * Gets Green attribute
   * of the RenderingSettings element.
   */
  public Integer getGreen() {
    return getIntegerAttribute("Green");
  }

  /**
   * Sets Green attribute
   * for the RenderingSettings element.
   */
  public void setGreen(Integer value) {
    setAttribute("Green", value);  }

  /**
   * Gets Blue attribute
   * of the RenderingSettings element.
   */
  public Integer getBlue() {
    return getIntegerAttribute("Blue");
  }

  /**
   * Sets Blue attribute
   * for the RenderingSettings element.
   */
  public void setBlue(Integer value) {
    setAttribute("Blue", value);  }

  /**
   * Gets Alpha attribute
   * of the RenderingSettings element.
   */
  public Integer getAlpha() {
    return getIntegerAttribute("Alpha");
  }

  /**
   * Sets Alpha attribute
   * for the RenderingSettings element.
   */
  public void setAlpha(Integer value) {
    setAttribute("Alpha", value);  }

  /**
   * Gets Active attribute
   * of the RenderingSettings element.
   */
  public Boolean isActive() {
    return getBooleanAttribute("Active");
  }

  /**
   * Sets Active attribute
   * for the RenderingSettings element.
   */
  public void setActive(Boolean value) {
    setAttribute("Active", value);  }

}
