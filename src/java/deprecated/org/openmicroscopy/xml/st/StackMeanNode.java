/*
 * org.openmicroscopy.xml.StackMeanNode
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
 * StackMeanNode is the node corresponding to the
 * "StackMean" XML element.
 *
 * Name: StackMean
 * AppliesTo: I
 * Location: OME/src/xml/OME/Import/ImageServerStatistics.ome
 */
public class StackMeanNode extends AttributeNode
  implements StackMean
{

  // -- Constructors --

  /**
   * Constructs a StackMean node
   * with the given associated DOM element.
   */
  public StackMeanNode(Element element) { super(element); }

  /**
   * Constructs a StackMean node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StackMeanNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a StackMean node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StackMeanNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "StackMean", attach);
  }

  /**
   * Constructs a StackMean node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public StackMeanNode(CustomAttributesNode parent, Integer theC, Integer theT,
    Float mean)
  {
    this(parent, true);
    setTheC(theC);
    setTheT(theT);
    setMean(mean);
  }


  // -- StackMean API methods --

  /**
   * Gets TheC attribute
   * of the StackMean element.
   */
  public Integer getTheC() {
    return getIntegerAttribute("TheC");
  }

  /**
   * Sets TheC attribute
   * for the StackMean element.
   */
  public void setTheC(Integer value) {
    setAttribute("TheC", value);  }

  /**
   * Gets TheT attribute
   * of the StackMean element.
   */
  public Integer getTheT() {
    return getIntegerAttribute("TheT");
  }

  /**
   * Sets TheT attribute
   * for the StackMean element.
   */
  public void setTheT(Integer value) {
    setAttribute("TheT", value);  }

  /**
   * Gets Mean attribute
   * of the StackMean element.
   */
  public Float getMean() {
    return getFloatAttribute("Mean");
  }

  /**
   * Sets Mean attribute
   * for the StackMean element.
   */
  public void setMean(Float value) {
    setAttribute("Mean", value);  }

}
