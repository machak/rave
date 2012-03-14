<%@ include file="/WEB-INF/jsp/includes/taglibs.jsp" %>
<%--
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
  --%>
<div id="personProfileSubPages">
    <div class="tabbable">
        <ul class="nav nav-tabs">
            <!-- first render the tabs -->
            <c:forEach var="subPage" items="${page.subPages}" varStatus="subPageStatus">
                <li><a data-toggle="tab" href="#subpage-${subPage.entityId}"><c:out value="${subPage.name}"/></a></li>
            </c:forEach>
        </ul>

        <div class="tab-content">
            <!-- now render the sub page bodies -->
            <c:forEach var="subPage" items="${page.subPages}" varStatus="subPageStatus">
                <div class="tab-pane" id="subpage-${subPage.entityId}">
                    <c:forEach var="subPageRegion" items="${subPage.regions}" varStatus="subPageRegionStatus">
                        <rave:region region="${subPageRegion}" regionIdx="${subPageRegionStatus.count}"/>
                    </c:forEach>
                </div>
            </c:forEach>
        </div>
    </div>
</div>