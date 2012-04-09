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
<%@ page language="java" trimDirectiveWhitespaces="true" %>
<%@ include file="/WEB-INF/jsp/includes/taglibs.jsp" %>
<fmt:setBundle basename="messages"/>
<jsp:useBean id="pages" type="java.util.List<org.apache.rave.portal.model.Page>" scope="request"/>
<%--@elvariable id="page" type="org.apache.rave.portal.model.Page"--%>
    <header class="header-mobile">
        <nav class="topnav">
            <ul class="horizontal-list">
                <li>
                    <a href="<spring:url value="/app/store?referringPageId=${page.entityId}" />">
                      <fmt:message key="page.store.title"/>
                    </a>
                </li>
                <sec:authorize url="/app/admin/">
                <li>
                    <a href="<spring:url value="/app/admin/"/>">
                        <fmt:message key="page.general.toadmininterface"/>
                    </a>
                </li>
                </sec:authorize>
                <li>
                    <a href="<spring:url value="/j_spring_security_logout" htmlEscape="true" />">
                      <fmt:message key="page.general.logout"/></a>
                </li>
            </ul>
        </nav>
        <h1>
            <fmt:message key="page.home.welcome"><fmt:param>
                <c:choose>
                    <c:when test="${not empty page.owner.displayName}"><c:out value="${page.owner.displayName}"/></c:when>
                    <c:otherwise><c:out value="${page.owner.username}"/></c:otherwise>
                </c:choose>
            </fmt:param></fmt:message>
        </h1>
    </header>
    <input id="currentPageId" type="hidden" value="${page.entityId}" />
    <c:set var="hasOnlyOnePage" scope="request">
        <c:choose>
            <c:when test="${fn:length(pages) == 1}">true</c:when>
            <c:otherwise>false</c:otherwise>
        </c:choose>
    </c:set>
    <div id="tabsHeader">
        <%-- render the page links --%>
        <div id="tabs" class="rave-ui-tabs">
            <c:forEach var="userPage" items="${pages}">
                 <%-- determine if the current page in the list matches the page the user is viewing --%>
                 <c:set var="isCurrentPage">
                     <c:choose>
                         <c:when test="${page.entityId == userPage.entityId}">true</c:when>
                         <c:otherwise>false</c:otherwise>
                     </c:choose>
                 </c:set>
                 <div id="tab-${userPage.entityId}" class="rave-ui-tab rave-ui-tab-mobile<c:if test="${isCurrentPage}"> rave-ui-tab-selected rave-ui-tab-selected-mobile</c:if>">
                    <div id="pageTitle-${userPage.entityId}" class="page-title" onclick="rave.viewPage(${userPage.entityId});"><c:out value="${userPage.name}"/></div>                   
                </div>
            </c:forEach>
            <%-- display the add page button at the end of the tabs --%>
            <fmt:message key="page.general.addnewpage" var="addNewPageTitle"/>
            <button id="add_page" title="${addNewPageTitle}" style="display: none;"></button>
        </div>
    </div>
    <%-- the mobile view will only show one column of widgets --%>
    <div id="pageContent" class="pageContent-mobile">        
        <c:forEach var="region" items="${page.regions}">
            <div class="region-mobile" id="region-${region.entityId}-id">
            <c:forEach var="regionWidget" items="${region.regionWidgets}">
               <div class="widget-wrapper widget-wrapper-mobile" id="widget-${regionWidget.entityId}-wrapper">
                    <div class="widget-title-bar widget-title-bar-mobile" onclick="rave.toggleMobileWidget(${regionWidget.entityId});">
                        <span id="widget-${regionWidget.entityId}-collapse" class="widget-toolbar-toggle-collapse" title="<fmt:message key="widget.chrome.toggle"/>"></span>
                        <div id="widget-${regionWidget.entityId}-title" class="widget-title">
                            <c:out value="${regionWidget.widget.title}"/>                        
                        </div>                        
                    </div>
                    <div class="widget-prefs" id="widget-${regionWidget.entityId}-prefs-content"></div>
                    <div class="widget widget-mobile" id="widget-${regionWidget.entityId}-body">
                            <portal:render-widget regionWidget="${regionWidget}" />
                    </div>
                </div>
            </c:forEach>
            </div>
        </c:forEach>
    </div>
    <fmt:message key="page.general.addnewpage" var="addNewPageTitle"/>
    <div id="dialog" title="${addNewPageTitle}" class="dialog hidden">
        <form id="pageForm">
            <div id="pageFormErrors" class="error"></div>
            <fieldset class="ui-helper-reset">
                <input type="hidden" name="tab_id" id="tab_id" value="" />
                <label for="tab_title"><fmt:message key="page.general.addpage.title"/></label>
                <input type="text" name="tab_title" id="tab_title" value="" class="required ui-widget-content ui-corner-all" />
                <label for="pageLayout"><fmt:message key="page.general.addpage.selectlayout"/></label>
                <select name="pageLayout" id="pageLayout">
                    <option value="columns_1" id="columns_1_id"><fmt:message key="page.general.addpage.layout.columns_1"/></option>
                    <option value="columns_2" id="columns_2_id" selected="selected"><fmt:message key="page.general.addpage.layout.columns_2"/></option>
                    <option value="columns_2wn" id="columns_2wn_id"><fmt:message key="page.general.addpage.layout.columns_2wn"/></option>
                    <option value="columns_3" id="columns_3_id"><fmt:message key="page.general.addpage.layout.columns_3"/></option>
                    <option value="columns_3nwn" id="columns_3nwn_id"><fmt:message key="page.general.addpage.layout.columns_3nwn"/></option>
                    <option value="columns_4" id="columns_4_id"><fmt:message key="page.general.addpage.layout.columns_4"/></option>
                    <option value="columns_3nwn_1_bottom" id="columns_3nwn_1_bottom"><fmt:message key="page.general.addpage.layout.columns_3nwn_1_bottom"/></option>
                </select>
            </fieldset>
        </form>
    </div>
    <fmt:message key="page.general.movepage" var="movePageTitle"/>
    <div id="movePageDialog" title="${movePageTitle}" class="dialog hidden">
        <div><fmt:message key="page.general.movethispage"/></div>
        <form id="movePageForm">
            <select id="moveAfterPageId">
                <c:if test="${page.renderSequence != 1}">
                    <option value="-1"><fmt:message key="page.general.movethispage.tofirst"/></option>
                </c:if>
                <c:forEach var="userPage" items="${pages}">
                    <c:if test="${userPage.entityId != page.entityId}">
                        <option value="${userPage.entityId}">
                          <fmt:message key="page.general.movethispage.after">
                              <fmt:param><c:out value="${userPage.name}"/></fmt:param>
                          </fmt:message>
                        </option>
                    </c:if>
                </c:forEach>
            </select>
        </form>
    </div>
    <fmt:message key="widget.menu.movetopage" var="moveWidgetToPageTitle"/>
    <div id="moveWidgetDialog" title="${moveWidgetToPageTitle}" class="dialog hidden">
        <div><fmt:message key="widget.menu.movethiswidget"/></div>
        <form id="moveWidgetForm">
            <select id="moveToPageId">
                <c:forEach var="userPage" items="${pages}">
                    <c:if test="${userPage.entityId != page.entityId}">
                        <option value="${userPage.entityId}">
                            <c:out value="${userPage.name}"/>
                        </option>
                    </c:if>
                </c:forEach>
            </select>
        </form>
    </div>

<portal:register-init-script location="${'BEFORE_RAVE'}">
    <script>
        //Define the global widgets map.  This map will be populated by RegionWidgetRender providers.
        var widgetsByRegionIdMap = {};
    </script>
</portal:register-init-script>

<portal:register-init-script location="${'AFTER_RAVE'}">
    <script>
        $(function() {
            rave.setMobile(true);
            rave.initProviders();
            rave.initWidgets(widgetsByRegionIdMap);           
        });
    </script>
</portal:register-init-script>