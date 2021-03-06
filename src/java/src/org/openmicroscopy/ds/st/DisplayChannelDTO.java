/*
 * org.openmicroscopy.ds.st.DisplayChannelDTO
 *
 *------------------------------------------------------------------------------
 *
 *  Copyright (C) 2003-2004 Open Microscopy Environment
 *      Massachusetts Institute of Technology,
 *      National Institutes of Health,
 *      University of Dundee
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
 *------------------------------------------------------------------------------
 */

/*------------------------------------------------------------------------------
 *
 * THIS IS AUTOMATICALLY GENERATED CODE.  DO NOT MODIFY.
 * Created by hochheiserha via omejava on Mon May  2 15:12:24 2005
 *
 *------------------------------------------------------------------------------
 */

package org.openmicroscopy.ds.st;

import org.openmicroscopy.ds.dto.Attribute;
import org.openmicroscopy.ds.st.DisplayOptions;
import org.openmicroscopy.ds.dto.AttributeDTO;
import java.util.List;
import java.util.Map;

public class DisplayChannelDTO
    extends AttributeDTO
    implements DisplayChannel
{
    public DisplayChannelDTO() { super(); }
    public DisplayChannelDTO(Map elements) { super(elements); }

    public String getDTOTypeName() { return "@DisplayChannel"; }
    public Class getDTOType() { return DisplayChannel.class; }

    public Float getGamma()
    { return getFloatElement("Gamma"); }
    public void setGamma(Float value)
    { setElement("Gamma",value); }

    public Double getWhiteLevel()
    { return getDoubleElement("WhiteLevel"); }
    public void setWhiteLevel(Double value)
    { setElement("WhiteLevel",value); }

    public Double getBlackLevel()
    { return getDoubleElement("BlackLevel"); }
    public void setBlackLevel(Double value)
    { setElement("BlackLevel",value); }

    public Integer getChannelNumber()
    { return getIntegerElement("ChannelNumber"); }
    public void setChannelNumber(Integer value)
    { setElement("ChannelNumber",value); }

    public List getDisplayOptionsListByBlueChannel()
    { return (List) parseListElement("DisplayOptionsListByBlueChannel",DisplayOptionsDTO.class); }
    public int countDisplayOptionsListByBlueChannel()
    { return countListElement("DisplayOptionsListByBlueChannel"); }

    public List getDisplayOptionsListByGreenChannel()
    { return (List) parseListElement("DisplayOptionsListByGreenChannel",DisplayOptionsDTO.class); }
    public int countDisplayOptionsListByGreenChannel()
    { return countListElement("DisplayOptionsListByGreenChannel"); }

    public List getDisplayOptionsListByGreyChannel()
    { return (List) parseListElement("DisplayOptionsListByGreyChannel",DisplayOptionsDTO.class); }
    public int countDisplayOptionsListByGreyChannel()
    { return countListElement("DisplayOptionsListByGreyChannel"); }

    public List getDisplayOptionsListByRedChannel()
    { return (List) parseListElement("DisplayOptionsListByRedChannel",DisplayOptionsDTO.class); }
    public int countDisplayOptionsListByRedChannel()
    { return countListElement("DisplayOptionsListByRedChannel"); }


}
