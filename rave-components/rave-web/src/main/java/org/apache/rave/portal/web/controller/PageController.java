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
package org.apache.rave.portal.web.controller;

import org.apache.rave.portal.model.Page;
import org.apache.rave.portal.model.PageLayout;
import org.apache.rave.portal.model.User;
import org.apache.rave.portal.service.PageLayoutService;
import org.apache.rave.portal.service.PageService;
import org.apache.rave.portal.service.UserService;
import org.apache.rave.portal.web.controller.util.ControllerUtils;
import org.apache.rave.portal.web.util.ModelKeys;
import org.apache.rave.portal.web.util.ViewNames;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * Page Controller
 * 
 * @author carlucci
 */
@Controller
public class PageController {
    private final Logger logger = LoggerFactory.getLogger(getClass());
         
    private PageService pageService;
    private UserService userService;
    private PageLayoutService pageLayoutService;

    @Autowired
    public PageController(PageService pageService, UserService userService, PageLayoutService pageLayoutService) {
        this.pageService = pageService;
        this.userService = userService;
        this.pageLayoutService = pageLayoutService;
    }

    @RequestMapping(value = {"/login"}, method = RequestMethod.GET)
    public String login() {
        return ViewNames.LOGIN_PAGE;
    }


    @RequestMapping(value = {"/page/view", "/index.html"}, method = RequestMethod.GET)
    public String viewDefault(Model model, HttpServletRequest request) {
        List<Page> pages = getAllPagesForAuthenticatedUser();
        Page page = pageService.getDefaultPageFromList(pages);
        List<PageLayout> pageLayouts = pageLayoutService.getAllUserSelectable();
        addAttributesToModel(model, page, pages, pageLayouts);
        return ControllerUtils.getDeviceAppropriateView(request, ViewNames.getPageView(page.getPageLayout().getCode()), ViewNames.MOBILE_HOME);
    }          
    
    @RequestMapping(value = "/page/view/{pageId}", method = RequestMethod.GET)
    public String view(@PathVariable Long pageId, Model model, HttpServletRequest request) {
        User user = userService.getAuthenticatedUser();
        logger.debug("attempting to get pageId {} for {}", pageId, user);
        
        List<Page> pages = getAllPagesForAuthenticatedUser();
        Page page = pageService.getPageFromList(pageId, pages);
        List<PageLayout> pageLayouts = pageLayoutService.getAllUserSelectable();
        addAttributesToModel(model, page, pages, pageLayouts);
        return ControllerUtils.getDeviceAppropriateView(request, ViewNames.getPageView(page.getPageLayout().getCode()), ViewNames.MOBILE_HOME);
    }
    
    private List<Page> getAllPagesForAuthenticatedUser() {
        User user = userService.getAuthenticatedUser();
        long userId = user.getEntityId();
        List<Page> pages = pageService.getAllUserPages(userId);
        if (pages.isEmpty()) {
            // create a new default page for the user
            logger.info("User {} does not have any pages - creating default page", user.getUsername());
            pageService.addNewDefaultUserPage(userId);
            // refresh the pages list which will now have the new page
            pages = pageService.getAllUserPages(userId);
        }
        return pages;
    }
    
    private void addAttributesToModel(Model model, Page page, List<Page> pages, List<PageLayout> pageLayouts) {
        model.addAttribute(ModelKeys.PAGE, page);
        model.addAttribute(ModelKeys.PAGES, pages);
        model.addAttribute(ModelKeys.PAGE_LAYOUTS, pageLayouts);
    }
}
