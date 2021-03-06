/*
 * org.openmicroscopy.xml.DisplayOptionsNode
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
 * DisplayOptionsNode is the node corresponding to the
 * "DisplayOptions" XML element.
 *
 * Name: DisplayOptions
 * AppliesTo: I
 * Location: OME/src/xml/OME/Core/Image.ome
 * Description: Parametros para visores para mostrar de forma optima la imagen.
 */
public class DisplayOptionsNode extends AttributeNode
  implements DisplayOptions
{

  // -- Constructors --

  /**
   * Constructs a DisplayOptions node
   * with the given associated DOM element.
   */
  public DisplayOptionsNode(Element element) { super(element); }

  /**
   * Constructs a DisplayOptions node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public DisplayOptionsNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a DisplayOptions node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public DisplayOptionsNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "DisplayOptions", attach);
  }

  /**
   * Constructs a DisplayOptions node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public DisplayOptionsNode(CustomAttributesNode parent, Pixels pixels,
    Float zoom, DisplayChannel redChannel, Boolean redChannelOn,
    DisplayChannel greenChannel, Boolean greenChannelOn,
    DisplayChannel blueChannel, Boolean blueChannelOn, Boolean displayRGB,
    DisplayChannel greyChannel, String colorMap, Integer zstart,
    Integer zstop, Integer tstart, Integer tstop)
  {
    this(parent, true);
    setPixels(pixels);
    setZoom(zoom);
    setRedChannel(redChannel);
    setRedChannelOn(redChannelOn);
    setGreenChannel(greenChannel);
    setGreenChannelOn(greenChannelOn);
    setBlueChannel(blueChannel);
    setBlueChannelOn(blueChannelOn);
    setDisplayRGB(displayRGB);
    setGreyChannel(greyChannel);
    setColorMap(colorMap);
    setZStart(zstart);
    setZStop(zstop);
    setTStart(tstart);
    setTStop(tstop);
  }


  // -- DisplayOptions API methods --

  /**
   * Gets Pixels referenced by Pixels
   * attribute of the DisplayOptions element.
   */
  public Pixels getPixels() {
    return (Pixels)
      getAttrReferencedNode("Pixels", "Pixels");
  }

  /**
   * Sets Pixels referenced by Pixels
   * attribute of the DisplayOptions element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of PixelsNode
   */
  public void setPixels(Pixels value) {
    setAttrReferencedNode((OMEXMLNode) value, "Pixels");
  }

  /**
   * Gets Zoom attribute
   * of the DisplayOptions element.
   */
  public Float getZoom() {
    return getFloatAttribute("Zoom");
  }

  /**
   * Sets Zoom attribute
   * for the DisplayOptions element.
   */
  public void setZoom(Float value) {
    setAttribute("Zoom", value);  }

  /**
   * Gets RedChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   */
  public DisplayChannel getRedChannel() {
    return (DisplayChannel)
      getAttrReferencedNode("DisplayChannel", "RedChannel");
  }

  /**
   * Sets RedChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of DisplayChannelNode
   */
  public void setRedChannel(DisplayChannel value) {
    setAttrReferencedNode((OMEXMLNode) value, "RedChannel");
  }

  /**
   * Gets RedChannelOn attribute
   * of the DisplayOptions element.
   */
  public Boolean isRedChannelOn() {
    return getBooleanAttribute("RedChannelOn");
  }

  /**
   * Sets RedChannelOn attribute
   * for the DisplayOptions element.
   */
  public void setRedChannelOn(Boolean value) {
    setAttribute("RedChannelOn", value);  }

  /**
   * Gets GreenChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   */
  public DisplayChannel getGreenChannel() {
    return (DisplayChannel)
      getAttrReferencedNode("DisplayChannel", "GreenChannel");
  }

  /**
   * Sets GreenChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of DisplayChannelNode
   */
  public void setGreenChannel(DisplayChannel value) {
    setAttrReferencedNode((OMEXMLNode) value, "GreenChannel");
  }

  /**
   * Gets GreenChannelOn attribute
   * of the DisplayOptions element.
   */
  public Boolean isGreenChannelOn() {
    return getBooleanAttribute("GreenChannelOn");
  }

  /**
   * Sets GreenChannelOn attribute
   * for the DisplayOptions element.
   */
  public void setGreenChannelOn(Boolean value) {
    setAttribute("GreenChannelOn", value);  }

  /**
   * Gets BlueChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   */
  public DisplayChannel getBlueChannel() {
    return (DisplayChannel)
      getAttrReferencedNode("DisplayChannel", "BlueChannel");
  }

  /**
   * Sets BlueChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of DisplayChannelNode
   */
  public void setBlueChannel(DisplayChannel value) {
    setAttrReferencedNode((OMEXMLNode) value, "BlueChannel");
  }

  /**
   * Gets BlueChannelOn attribute
   * of the DisplayOptions element.
   */
  public Boolean isBlueChannelOn() {
    return getBooleanAttribute("BlueChannelOn");
  }

  /**
   * Sets BlueChannelOn attribute
   * for the DisplayOptions element.
   */
  public void setBlueChannelOn(Boolean value) {
    setAttribute("BlueChannelOn", value);  }

  /**
   * Gets DisplayRGB attribute
   * of the DisplayOptions element.
   */
  public Boolean isDisplayRGB() {
    return getBooleanAttribute("DisplayRGB");
  }

  /**
   * Sets DisplayRGB attribute
   * for the DisplayOptions element.
   */
  public void setDisplayRGB(Boolean value) {
    setAttribute("DisplayRGB", value);  }

  /**
   * Gets GreyChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   */
  public DisplayChannel getGreyChannel() {
    return (DisplayChannel)
      getAttrReferencedNode("DisplayChannel", "GreyChannel");
  }

  /**
   * Sets GreyChannel referenced by DisplayChannel
   * attribute of the DisplayOptions element.
   *
   * @throws ClassCastException
   *   if parameter is not an instance of DisplayChannelNode
   */
  public void setGreyChannel(DisplayChannel value) {
    setAttrReferencedNode((OMEXMLNode) value, "GreyChannel");
  }

  /**
   * Gets ColorMap attribute
   * of the DisplayOptions element.
   */
  public String getColorMap() {
    return getAttribute("ColorMap");
  }

  /**
   * Sets ColorMap attribute
   * for the DisplayOptions element.
   */
  public void setColorMap(String value) {
    setAttribute("ColorMap", value);  }

  /**
   * Gets ZStart attribute
   * of the DisplayOptions element.
   */
  public Integer getZStart() {
    return getIntegerAttribute("ZStart");
  }

  /**
   * Sets ZStart attribute
   * for the DisplayOptions element.
   */
  public void setZStart(Integer value) {
    setAttribute("ZStart", value);  }

  /**
   * Gets ZStop attribute
   * of the DisplayOptions element.
   */
  public Integer getZStop() {
    return getIntegerAttribute("ZStop");
  }

  /**
   * Sets ZStop attribute
   * for the DisplayOptions element.
   */
  public void setZStop(Integer value) {
    setAttribute("ZStop", value);  }

  /**
   * Gets TStart attribute
   * of the DisplayOptions element.
   */
  public Integer getTStart() {
    return getIntegerAttribute("TStart");
  }

  /**
   * Sets TStart attribute
   * for the DisplayOptions element.
   */
  public void setTStart(Integer value) {
    setAttribute("TStart", value);  }

  /**
   * Gets TStop attribute
   * of the DisplayOptions element.
   */
  public Integer getTStop() {
    return getIntegerAttribute("TStop");
  }

  /**
   * Sets TStop attribute
   * for the DisplayOptions element.
   */
  public void setTStop(Integer value) {
    setAttribute("TStop", value);  }

  /**
   * Gets a list of DisplayROI elements
   * referencing this DisplayOptions node.
   */
  public List getDisplayROIList() {
    return getAttrReferringNodes("DisplayROI", "DisplayOptions");
  }

  /**
   * Gets the number of DisplayROI elements
   * referencing this DisplayOptions node.
   */
  public int countDisplayROIList() {
    return getAttrReferringCount("DisplayROI", "DisplayOptions");
  }

}
