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

<fmt:message key="${pageTitleKey}" var="pagetitle"/>

<rave:header pageTitle="${pagetitle}"/>

<rave:admin_tabsheader/>


<article class="row-fluid">
    <%--@elvariable id="actionresult" type="java.lang.String"--%>
    <c:if test="${actionresult eq 'delete' or actionresult eq 'update' or actionresult eq 'create'}">
        <div class="alert-message success">
            <fmt:message key="admin.categoryDetail.action.${actionresult}.success"/>
        </div>
    </c:if>
    <h2><fmt:message key="admin.category.shortTitle"/></h2>


    <div class="span6">
        <table class="datatable categoryTable">
            <thead>
            <tr>
                <th class="largetextcell"><fmt:message key="admin.categoryData.text"/></th>
                <th class="textcell"><fmt:message key="admin.categoryData.createdBy"/></th>
                <th class="textcell"><fmt:message key="admin.categoryData.createdDate"/></th>
                <th class="textcell"><fmt:message key="admin.categoryData.modifiedBy"/></th>
                <th class="textcell"><fmt:message key="admin.categoryData.modifiedDate"/></th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${categories}" var="category">
                <spring:url value="/app/admin/category/edit?id=${category.entityId}" var="detaillink"/>

                <tr data-detaillink="${detaillink}">
                    <td class="largetextcell">
                        <c:out value="${category.text}"/>
                    </td>
                    <td class="textcell">
                        <c:out value="${category.createdUser.username}"/>
                    </td>
                    <td class="textcell">
                        <c:out value="${category.createdDate}"/>
                    </td>
                    <td class="textcell">
                        <c:out value="${category.lastModifiedUser.username}"/>
                    </td>
                    <td class="textcell">
                        <c:out value="${category.lastModifiedDate}"/>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

    </div>

    <div class="span4">
        <form:form cssClass="form-horizontal well" commandName="category" action="category/create" method="POST">
            <form:errors cssClass="error" element="p"/>
            <fieldset>
                <legend><fmt:message key="admin.category.create"/></legend>
                <input type="hidden" name="token" value="<c:out value="${tokencheck}"/>"/>
                <div class="control-group">
                    <label class="control-label" for="text"><fmt:message key="admin.categoryDetail.label.text"/></label>
                    <div class="controls">
                        <form:input id="text" path="text" required="required" autofocus="autofocus"/>
                        <form:errors path="text" cssClass="error"/></div>
                </div>
            </fieldset>
            <fieldset>
                <fmt:message key="admin.category.create" var="createCategoryMsg"/>
                <div class="controls">
                    <button class="btn btn-primary" type="submit" value="${createCategoryMsg}">${createCategoryMsg}</button>
                </div>

            </fieldset>
        </form:form></div>
</article>
</div>

<script src="//ajax.aspnetcdn.com/ajax/jQuery/jquery-1.6.4.min.js"></script>
<script src="<spring:url value="/script/rave_admin.js"/>"></script>
<script>$(function () {
    rave.admin.initAdminUi();
});</script>
