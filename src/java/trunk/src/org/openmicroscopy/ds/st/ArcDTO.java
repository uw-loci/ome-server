/*
 * org.openmicroscopy.ds.st.ArcDTO
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
 * Created by dcreager via omejava on Tue Feb 24 17:23:15 2004
 *
 *------------------------------------------------------------------------------
 */

package org.openmicroscopy.ds.st;

import org.openmicroscopy.ds.dto.Attribute;
import org.openmicroscopy.ds.st.LightSource;
import org.openmicroscopy.ds.dto.AttributeDTO;
import java.util.List;
import java.util.Map;

public class ArcDTO
    extends AttributeDTO
    implements Arc
{
    public ArcDTO() { super(); }
    public ArcDTO(Map elements) { super(elements); }

    public String getDTOTypeName() { return "@Arc"; }
    public Class getDTOType() { return Arc.class; }

    public String getType()
    { return getStringElement("Type"); }
    public void setType(String value)
    { setElement("Type",value); }

    public Float getPower()
    { return getFloatElement("Power"); }
    public void setPower(Float value)
    { setElement("Power",value); }

    public LightSource getLightSource()
    { return (LightSource) getObjectElement("LightSource"); }
    public void setLightSource(LightSource value)
    { setElement("LightSource",value); }

    public void setMap(Map elements)
    {
        super.setMap(elements);
        parseChildElement("LightSource",LightSourceDTO.class);
    }

}