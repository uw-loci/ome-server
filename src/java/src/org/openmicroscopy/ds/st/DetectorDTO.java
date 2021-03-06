/*
 * org.openmicroscopy.ds.st.DetectorDTO
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
 * Created by hochheiserha via omejava on Mon May  2 15:12:23 2005
 *
 *------------------------------------------------------------------------------
 */

package org.openmicroscopy.ds.st;

import org.openmicroscopy.ds.dto.Attribute;
import org.openmicroscopy.ds.st.Instrument;
import org.openmicroscopy.ds.st.LogicalChannel;
import org.openmicroscopy.ds.dto.AttributeDTO;
import java.util.List;
import java.util.Map;

public class DetectorDTO
    extends AttributeDTO
    implements Detector
{
    public DetectorDTO() { super(); }
    public DetectorDTO(Map elements) { super(elements); }

    public String getDTOTypeName() { return "@Detector"; }
    public Class getDTOType() { return Detector.class; }

    public Instrument getInstrument()
    { return (Instrument) parseChildElement("Instrument",InstrumentDTO.class); }
    public void setInstrument(Instrument value)
    { setElement("Instrument",value); }

    public Float getOffset()
    { return getFloatElement("Offset"); }
    public void setOffset(Float value)
    { setElement("Offset",value); }

    public Float getVoltage()
    { return getFloatElement("Voltage"); }
    public void setVoltage(Float value)
    { setElement("Voltage",value); }

    public Float getGain()
    { return getFloatElement("Gain"); }
    public void setGain(Float value)
    { setElement("Gain",value); }

    public String getType()
    { return getStringElement("Type"); }
    public void setType(String value)
    { setElement("Type",value); }

    public String getSerialNumber()
    { return getStringElement("SerialNumber"); }
    public void setSerialNumber(String value)
    { setElement("SerialNumber",value); }

    public String getModel()
    { return getStringElement("Model"); }
    public void setModel(String value)
    { setElement("Model",value); }

    public String getManufacturer()
    { return getStringElement("Manufacturer"); }
    public void setManufacturer(String value)
    { setElement("Manufacturer",value); }

    public List getLogicalChannelList()
    { return (List) parseListElement("LogicalChannelList",LogicalChannelDTO.class); }
    public int countLogicalChannelList()
    { return countListElement("LogicalChannelList"); }


}
