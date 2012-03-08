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
<jsp:useBean id="pageLayouts" type="java.util.List<org.apache.rave.portal.model.PageLayout>" scope="request"/>
<%--@elvariable id="page" type="org.apache.rave.portal.model.Page"--%>
<header class="navbar navbar-fixed-top">
    <nav>
        <a class="brand" href="#">
            <fmt:message key="page.home.welcome"><fmt:param>
                <c:choose>
                    <c:when test="${not empty page.owner.displayName}"><c:out value="${page.owner.displayName}"/></c:when>
                    <c:otherwise><c:out value="${page.owner.username}"/></c:otherwise>
                </c:choose>
            </fmt:param>
            </fmt:message>

        </a>
        <ul class="nav pull-right">
            <li>
                <c:set var="profileUrl">/app/person/<sec:authentication property="principal.username"/>?referringPageId=${page.entityId}
                </c:set>
                <a href="<spring:url value="${profileUrl}" />">
                    <fmt:message key="page.profile.title">
                        <fmt:param><c:out value="${page.owner.displayName}"/></fmt:param>
                    </fmt:message>
                </a>
            </li>
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
</header>


<input id="currentPageId" type="hidden" value="${page.entityId}"/>
<c:set var="hasOnlyOnePage" scope="request">
    <c:choose>
        <c:when test="${fn:length(pages) == 1}">true</c:when>
        <c:otherwise>false</c:otherwise>
    </c:choose>
</c:set>

<%--  TODO mm: create spacing--%>
<div class="container-fluid" style="margin-top: 50px;">
    <nav>
        <ul class="nav nav-tabs">
            <c:forEach var="userPage" items="${pages}">
                <%-- determine if the current page in the list matches the page the user is viewing --%>
                <c:set var="isCurrentPage">
                    <c:choose>
                        <c:when test="${page.entityId == userPage.entityId}">true</c:when>
                        <c:otherwise>false</c:otherwise>
                    </c:choose>
                </c:set>
                <c:choose>
                    <c:when test="${isCurrentPage}">
                        <li id="tab-${userPage.entityId}" class="active" onclick="rave.viewPage(${userPage.entityId});"><c:out value="${userPage.name}"/></li>
                        <li class="dropdown">
                            <ul class="dropdown-menu">
                                <li id="pageMenu" class="page-menu">Menu</li>
                                <li id="pageMenuEdit" class="page-menu-item">
                                    <fmt:message key="page.general.editpage"/></li>
                                <li id="pageMenuDelete"><fmt:message key="page.general.deletepage"/></li>
                                <li id="pageMenuMove"><fmt:message key="page.general.movepage"/></li>

                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li id="tab-${userPage.entityId}" onclick="rave.viewPage(${userPage.entityId});"><c:out value="${userPage.name}"/></li>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </ul>


    </nav>


    <div class="row-fluid">
        <div id="emptyPageMessageWrapper" class="emptyPageMessageWrapper hidden">
            <div class="emptyPageMessage">
                <a href="<spring:url value="/app/store?referringPageId=${page.entityId}" />"><fmt:message key="page.general.empty"/></a>
            </div>
        </div>
        <div class="regions">
            <%-- insert the region layout template --%>
            <tiles:insertTemplate template="${layout}"/>
        </div>
        <div class="clear-float">&nbsp;</div>
    </div>
    <fmt:message key="page.general.addnewpage" var="addNewPageTitle"/>
    <div id="dialog" title="${addNewPageTitle}" class="dialog hidden">
        <form id="pageForm">
            <div id="pageFormErrors" class="error"></div>
            <fieldset class="ui-helper-reset">
                <input type="hidden" name="tab_id" id="tab_id" value=""/>
                <label for="tab_title"><fmt:message key="page.general.addpage.title"/></label>
                <input type="text" name="tab_title" id="tab_title" value="" class="required ui-widget-content ui-corner-all"/>
                <label for="pageLayout"><fmt:message key="page.general.addpage.selectlayout"/></label>
                <select name="pageLayout" id="pageLayout">
                    <c:forEach var="pageLayout" items="${pageLayouts}">
                        <option value="${pageLayout.code}" id="${pageLayout.code}_id">
                            <fmt:message key="page.general.addpage.layout.${pageLayout.code}"/></option>
                    </c:forEach>
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
</div>

<script>
    //Define the global widgets map.  This map will be populated by RegionWidgetRender providers.
    var widgetsByRegionIdMap = {};
</script>
<portal:render-script location="${'BEFORE_LIB'}" />
<script src="//cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.6.4.min.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jquery.ui/1.8.16/jquery-ui.min.js"></script>
<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
<!--[if lt IE 9]><script src=//css3-mediaqueries-js.googlecode.com/svn/trunk/css3-mediaqueries.js></script><![endif]-->
<portal:render-script location="${'AFTER_LIB'}" />
<portal:render-script location="${'BEFORE_RAVE'}" />
<script src="<spring:url value="/script/rave.js"/>"></script>
<script src="<spring:url value="/script/rave_api.js"/>"></script>
<script src="<spring:url value="/script/rave_opensocial.js"/>"></script>
<script src="<spring:url value="/script/rave_wookie.js"/>"></script>
<script src="<spring:url value="/script/rave_layout.js"/>"></script>
<script src="<spring:url value="/app/messagebundle/rave_client_messages.js"/>"></script>
<portal:render-script location="${'AFTER_RAVE'}" />
<script>
    $(function() {
        rave.setContext("<spring:url value="/app/" />");
        rave.initProviders();
        rave.initWidgets(widgetsByRegionIdMap);
        rave.initUI();
        rave.layout.init();
    });
</script>
