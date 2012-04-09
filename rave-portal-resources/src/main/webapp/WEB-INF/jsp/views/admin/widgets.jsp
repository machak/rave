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
<%--@elvariable id="searchResult" type="org.apache.rave.portal.model.util.SearchResult<org.apache.rave.portal.model.Widget>"--%>
<fmt:message key="${pageTitleKey}" var="pagetitle"/>
<rave:header pageTitle="${pagetitle}"/>
<div class="container-fluid">
    <div class="span3">
        <rave:admin_tabsheader/>
    </div>
    <article class="span12">
        <c:if test="${actionresult eq 'delete' or actionresult eq 'update'}">
            <div class="alert alert-info">
                <p>
                    <fmt:message key="admin.widgetdetail.action.${actionresult}.success"/>
                </p>
            </div>
        </c:if>

        <rave:admin_listheader/>
        <rave:admin_paging/>

        <c:if test="${searchResult.totalResults > 0}">
            <table class="table table-striped table-bordered table-condensed">
                <thead>
                <tr>
                    <th><fmt:message key="widget.title"/></th>
                    <th><fmt:message key="widget.type"/></th>
                    <th><fmt:message key="widget.widgetStatus"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="widget" items="${searchResult.resultSet}">
                    <spring:url value="/app/admin/widgetdetail/${widget.entityId}" var="detaillink"/>
                    <tr data-detaillink="${detaillink}">
                        <td><a href="${detaillink}"><c:out value="${widget.title}"/></a></td>
                        <td><fmt:message key="widget.type.${widget.type}"/></td>
                        <td><c:out value="${widget.widgetStatus}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:if>

        <rave:admin_paging/>

    </article>
    <div class="span6">
        <form class="form-horizontal" action="<spring:url value="/app/admin/widgets/search"/>" method="get">
            <fieldset>
                <label for="searchTerm" class="hidden"><fmt:message key="admin.widgets.search"/></label>
                <input class="search-query" type="search" id="searchTerm" name="searchTerm"
                       value="<c:out value="${searchTerm}"/>"/>
                <fmt:message key="page.store.search.button" var="searchButtonText"/>
                <button class="btn btn-primary" type="submit" value="${searchButtonText}">${searchButtonText}</button>
                <div class="control-group"></div>
                <div class="control-group">
                    <label for="widgettype" class="hidden"><fmt:message key="widget.type"/></label>
                    <select name="widgettype" id="widgettype">
                        <option value=""><fmt:message key="admin.widgets.search.choosetype"/></option>
                        <option value="OpenSocial"
                                <c:if test="${selectedWidgetType eq 'OpenSocial'}"> selected="selected"</c:if>>
                            <fmt:message key="widget.type.OpenSocial"/></option>
                        <option value="W3C" <c:if test="${selectedWidgetType eq 'W3C'}"> selected="selected"</c:if>>
                            <fmt:message key="widget.type.W3C"/></option>
                    </select></div>
                <label for="widgetstatus" class="hidden"><fmt:message key="widget.widgetStatus"/></label>
                <select name="widgetstatus" id="widgetstatus">
                    <option value=""><fmt:message key="admin.widgets.search.choosestatus"/></option>
                    <c:forEach items="${widgetStatus}" var="wStatus">
                        <option value="<c:out value="${wStatus.widgetStatus}"/>"
                                <c:if test="${wStatus.widgetStatus eq selectedWidgetStatus}"> selected="selected"</c:if>>
                            <c:out value="${wStatus.widgetStatus}"/></option>
                    </c:forEach>
                </select>

            </fieldset>
        </form>
        <c:if test="${not empty searchTerm or not empty selectedWidgetType or not empty selectedWidgetStatus}">
            <a href="<spring:url value="/app/admin/widgets"/>"><fmt:message key="admin.clearsearch"/></a>
        </c:if>
    </div>
</div>

<portal:register-init-script location="${'AFTER_RAVE'}">
    <script>
        $(function() {
            rave.admin.initAdminUi();
        });
    </script>
</portal:register-init-script>