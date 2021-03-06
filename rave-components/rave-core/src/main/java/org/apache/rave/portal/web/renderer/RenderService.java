/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.rave.portal.web.renderer;

import org.apache.rave.portal.model.RegionWidget;
import org.apache.rave.portal.web.renderer.model.RenderContext;

import java.util.Collection;

/**
 *  Renders model objects as strings that can be inserted into the view
 */
public interface RenderService {
    /**
     * Gets the types of widgets supported by this rendering service
     * @return a collection of strings corresponding to the widget types
     */
    Collection<String> getSupportedWidgetTypes();

    /**
     * Renders the {@link org.apache.rave.portal.model.RegionWidget} as a String
     *
     *
     * @param widget widget to renderer
     * @param context the cotnext under which to render the widget
     * @return a String representing the rendered widget
     */
    String render(RegionWidget widget, RenderContext context);

}
