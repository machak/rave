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
<div class="container-fluid navigation-spacer">
  <div class="row">
    <div class="span3">
      <rave:admin_tabsheader/>
    </div>
    <article class="span9">
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


  </div>

</div>

<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.6.4.min.js"></script>
<script src="<spring:url value="/script/rave_admin.js"/>"></script>
<script>$(function () {
    rave.admin.initAdminUi();
});</script>