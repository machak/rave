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

var rave = rave || {};
rave.layout = rave.layout || (function() {
    var MOVE_PAGE_DEFAULT_POSITION_IDX = -1;
    var $moveWidgetDialog;
    var $movePageDialog = $("#movePageDialog");
    var $pageForm = $("#pageForm");
    var $tab_title_input = $("#tab_title"),
        $tab_id = $("#tab_id"),
        $page_layout_input = $("#pageLayout");
    
    // page menu related functions
    var pageMenu = (function() {
        var $addPageButton = $("#addPageButton");
        var $menuItemEdit = $("#pageMenuEdit");
        var $menuItemDelete = $("#pageMenuDelete");
        var $menuItemMove = $("#pageMenuMove");

        /**
         * Initializes the private pageMenu closure
         * - binds click event handler to menu button
         * - binds menu item click event handlers
         * - binds body click event handler to close the menu
         */
        function init() {
            // initialize the page form validator overriding the
            // styles to wire in bootstrap styles
            $pageForm.validate({
                errorElement: 'span',
                errorClass: 'help-inline',
                highlight: function (element, errorClass) {
                    $(element).parent().parent().addClass('error');
                },
                unhighlight: function (element, errorClass) {
                    $(element).parent().parent().removeClass('error');
                }
            });

            // initialize the close button in the page menu dialog
            $("#pageMenuCloseButton").click(rave.layout.closePageDialog);

            // setup the edit page menu item
            $addPageButton.bind('click', function(event) {
                $("#pageMenuDialogHeader").html(rave.getClientMessage("page.add"));
                var $pageMenuUpdateButton = $("#pageMenuUpdateButton");
                $pageMenuUpdateButton.html(rave.getClientMessage("common.add"));
                // unbind the previous click event since we are sharing the
                // dialog between separate add/edit page actions
                $pageMenuUpdateButton.unbind('click');
                $pageMenuUpdateButton.click(rave.layout.addPage);
                $("#pageMenuDialog").modal('show');
            });

            // setup the edit page menu item
            $menuItemEdit.bind('click', function(event) {
                 rave.api.rpc.getPagePrefs({pageId: getCurrentPageId(),
                                        successCallback: function(result) {
                                            $tab_title_input.val(result.result.name);
                                            $tab_id.val(result.result.entityId);
                                            $page_layout_input.val(result.result.pageLayout.code);
                                            $("#pageMenuDialogHeader").html(rave.getClientMessage("page.update"));
                                            var $pageMenuUpdateButton = $("#pageMenuUpdateButton");
                                            $pageMenuUpdateButton.html(rave.getClientMessage("common.save"));
                                            // unbind the previous click event since we are sharing the
                                            // dialog between separate add/edit page actions
                                            $pageMenuUpdateButton.unbind('click');
                                            $pageMenuUpdateButton.click(rave.layout.updatePage);
                                            $("#pageMenuDialog").modal('show');
                                        }
                });
            });

            // setup the delete page menu item if it is not disabled
            if (!$menuItemDelete.hasClass("menu-item-disabled")) {
                $menuItemDelete.bind('click', function(event) {
                    // send the rpc request to delete the page
                    rave.api.rest.deletePage({pageId: getCurrentPageId(), successCallback: rave.viewPage});
                });
            }

            // setup the move page menu item if it is not disabled
            if (!$menuItemMove.hasClass("menu-item-disabled")) {
                $menuItemMove.bind('click', function(event) {
                    $movePageDialog.modal('show');
                });      
            }
        }
        
        return {
            init: init
        }
    })();

    // widget menu related functions
    var widgetMenu = (function() {
        var $menu;
        var $menuItemMove;
        var $menuItemDelete;
        var $menuItemMaximize;

        /**
         * Hides the widget menu for a specific widget
         * @param widgetId the id of the widget to hide the menu for
         */
        function hideMenu(widgetId) {
            $("#widget-" + widgetId + "-menu").hide();
        }        
        /**
         * Hides all widget menus     
         */
        function hideAllMenus() {
            $(".widget-menu").hide();
        }        
        /**
         * Shows the widget menu for a specific widget
         * @param widgetId the id of the widget to show the menu for
         */
        function showMenu(widgetId) {
            $("#widget-" + widgetId + "-menu").show();
        }

        /**
         * Initializes the private widgetMenu closure
         * - binds click event handler to menu button
         * - binds menu item click event handlers
         * - binds body click event handler to close the menu
         */
        function init() {
            // the modal dialog for moving a widget
            $moveWidgetDialog = $("#moveWidgetDialog").dialog({
                autoOpen: false,
                modal: true,
                buttons: [
                    {
                        text: rave.getClientMessage("common.move"),
                        click: function() {
                            moveWidgetToPage($(this).data('regionWidgetId'));
                        }
                    },
                    {
                        text: rave.getClientMessage("common.cancel"),
                        click: function() {
                            $(this).dialog("close");
                        }
                    }
                ],
                open: function() {
                    $("#moveToPageId").focus();
                },
                close: function() {
                    $("#moveWidgetForm")[0].reset();
                }
            });

            // initialize the widget menu and button
            $(".widget-menu-button").each(function(index, element) {
                if (!$(element).hasClass("widget-menu-item-disabled")) {
                    $(element).bind('click', function(event) {
                        $menu = $("#widget-" + rave.getObjectIdFromDomId(this.id) + "-menu");                        
                        $menu.toggle();
                        // prevent the menu button click event from bubbling up to parent
                        // DOM object event handlers such as the page tab click event
                        event.stopPropagation();
                    });
                }
            });

            // loop over each widget-menu and initialize the menu items
            // note: the edit prefs menu item is by default rendered disabled
            //       and it is up to the provider code for that widget to 
            //       determine if the widget has preferences, and to enable
            //       the menu item
            $(".widget-menu").each(function(index, element){
                var widgetId = rave.getObjectIdFromDomId(element.id);
                                
                // setup the move to page menu item
                $menuItemMove = $("#widget-" + widgetId + "-menu-move-item");
                if (!$menuItemMove.hasClass("widget-menu-item-disabled")) {
                    $menuItemMove.bind('click', function(event) {                       
                        var regionWidgetId = rave.getObjectIdFromDomId(this.id);
                        $moveWidgetDialog
                            .data('regionWidgetId', regionWidgetId)
                            .dialog("open");
                            
                        // hide the widget menu
                        rave.layout.hideWidgetMenu(regionWidgetId);                       
                            
                        // prevent the menu button click event from bubbling up to parent
                        // DOM object event handlers such as the page tab click event
                        event.stopPropagation();
                    });
                }    
                
                // setup the delete widget menu item
                $menuItemDelete  = $("#widget-" + widgetId + "-menu-delete-item");
                if (!$menuItemDelete.hasClass("widget-menu-item-disabled")) {
                    $menuItemDelete.bind('click', function(event) {                       
                        var regionWidgetId = rave.getObjectIdFromDomId(this.id);
                         // hide the widget menu
                        rave.layout.hideWidgetMenu(regionWidgetId);                                         
                        // invoke the rpc call to remove the widget from the page
                        rave.layout.deleteRegionWidget(regionWidgetId);
                                                                                                                                                     
                        // prevent the menu button click event from bubbling up to parent
                        // DOM object event handlers such as the page tab click event
                        event.stopPropagation();
                    });
                }    
                
                // setup the maximize widget menu item
                $menuItemMaximize  = $("#widget-" + widgetId + "-menu-maximize-item");
                if (!$menuItemMaximize.hasClass("widget-menu-item-disabled")) {
                    $menuItemMaximize.bind('click', function(event) {                       
                        var regionWidgetId = rave.getObjectIdFromDomId(this.id); 
                         // hide the widget menu
                        rave.layout.hideWidgetMenu(regionWidgetId);                                         
                        // maximize the widget
                        rave.maximizeWidget({data: {id: regionWidgetId}});                                                                                                                                                     
                        // prevent the menu button click event from bubbling up to parent
                        // DOM object event handlers such as the page tab click event
                        event.stopPropagation();
                    });
                }

                // setup the about this widget menu item
                $menuItemAbout  = $("#widget-" + widgetId + "-menu-about-item");
                if (!$menuItemAbout.hasClass("widget-menu-item-disabled")) {
                    $menuItemAbout.bind('click', function(event) {
                        var regionWidget = rave.getRegionWidgetById(rave.getObjectIdFromDomId(this.id));
                        // hide the widget menu
                        rave.layout.hideWidgetMenu(regionWidget.regionWidgetId);
                        // go to the widget detail page
                        rave.viewWidgetDetail(regionWidget.widgetId, getCurrentPageId());
                        // prevent the menu button click event from bubbling up to parent
                        // DOM object event handlers such as the page tab click event
                        event.stopPropagation();
                    });
                }
            });

            // close the widget menu if the user clicks outside of it
            $("html").click(widgetMenu.hideAll);
        }
        
        /**
         * Enables the Edit Prefs including the Preferences view (Custom Edit Prefs)
         * menu item in the widget menu to be clicked.
         * Widget providers should use this function when initializing their
         * widgets after determining if the widget has preferences to modify.
         * 
         * @param regionWidgetId the regionWidgetId of the regionWidget menu to enable
         * @param isPreferencesView boolean to indicate whether "preferences" view or the default prefs view
         */
        function enableEditPrefsMenuItem(regionWidgetId, isPreferencesView) {
            // setup the edit prefs widget menu item
            var $menuItemEditPrefs  = $("#widget-" + regionWidgetId + "-menu-editprefs-item");
            $menuItemEditPrefs.removeClass("widget-menu-item-disabled");           
            $menuItemEditPrefs.bind('click', function(event) {                       
                var regionWidgetId = rave.getObjectIdFromDomId(this.id); 
                 // hide the widget menu
                rave.layout.hideWidgetMenu(regionWidgetId);
                // show the regular edit prefs or the Custom Edit Prefs(preferences) region
                if ( isPreferencesView )
                    rave.editCustomPrefs({data: {id: regionWidgetId}});
                else
                    rave.editPrefs(regionWidgetId);
                // prevent the menu button click event from bubbling up to parent
                // DOM object event handlers such as the page tab click event
                event.stopPropagation();
            });                
        }

        return {
            init: init,
            hideAll: hideAllMenus,
            hide: hideMenu,            
            show: showMenu,
            enableEditPrefsMenuItem: enableEditPrefsMenuItem
        }
    })();

    /**
     * Submits the RPC call to move the widget to a new page
     */
    function moveWidgetToPage(regionWidgetId) {
        var toPageId = $("#moveToPageId").val();
        var args = { toPageId: toPageId,
                     regionWidgetId: regionWidgetId,
                     successCallback: function() { rave.viewPage(toPageId); }
                   };
        // send the rpc request to move the widget to new page
        rave.api.rpc.moveWidgetToPage(args);
    }

    /**
     * Submits the RPC call to add a new page if form validation passes
     */        
    function addPage() {
        // if the form has passed validation submit the request
        if ($pageForm.valid()) {
            var newPageTitle = $tab_title_input.val();
            var newPageLayoutCode = $page_layout_input.val();

            // send the rpc request to create the new page
            rave.api.rpc.addPage({pageName: newPageTitle, 
                                  pageLayoutCode: newPageLayoutCode,
                                  successCallback: function(result) {                                      
                                      rave.viewPage(result.result.entityId); 
                                  } 
            });      
        }
    }      

    /**
     * Submits the RPC call to move the page to a new render sequence
     */        
    function movePage() {
        var moveAfterPageId = $("#moveAfterPageId").val();
        var args = { pageId: $("#currentPageId").val(),
                     successCallback: function(result) { rave.viewPage(result.result.entityId); }
                   };
       
        if (moveAfterPageId != MOVE_PAGE_DEFAULT_POSITION_IDX) {
            args["moveAfterPageId"] = moveAfterPageId;
        }
                          
        // send the rpc request to move the new page
        rave.api.rpc.movePage(args);              
    }

    function updatePage() {
        if ($pageForm.valid()) {
            // send the rpc request to update the page
            rave.api.rpc.updatePagePrefs({pageId: $tab_id.val(),
                                            title: $tab_title_input.val(),
                                            layout: $page_layout_input.val(),
                                            successCallback: function(result) {
                                                rave.viewPage(result.result.entityId);
                                            }});
        }
    }

    function closePageDialog() {
        $pageForm[0].reset();
        $tab_id.val('');
        $("#pageMenuDialog").modal("hide");
    }
    
    /**
     * Invokes the RPC call to delete a regionWidget from a page
     *
     * @param regionWidgetId the regionWidgetId to delete
     */
    function deleteRegionWidget(regionWidgetId) {
        if (confirm(rave.getClientMessage("widget.remove_confirm"))) {
            rave.api.rpc.removeWidget({
                regionWidgetId: regionWidgetId,
                successCallback: function() {
                    // remove the widget from the dom and the internal memory map
                    $("#widget-" + this.regionWidgetId + "-wrapper").remove();                    
                    rave.removeWidgetFromMap(this.regionWidgetId);
                    if (rave.isPageEmpty()) {
                        rave.displayEmptyPageMessage();
                    }
                }
            });
        }
    }
    
    /**
     * Returns the pageId of the currently viewed page
     */
    function getCurrentPageId() {
        return $("#currentPageId").val();
    }
       
   /***
    * initializes the rave.layout namespace code
    */
    function init() {
        pageMenu.init();
        widgetMenu.init();
        // initialize the bootstrap dropdowns
        $(".dropdown-toggle").dropdown();
    }
   
    // public rave.layout API
    return {
        init: init,
        getCurrentPageId: getCurrentPageId,
        hideWidgetMenu: widgetMenu.hide,
        deleteRegionWidget: deleteRegionWidget,
        enableEditPrefsMenuItem: widgetMenu.enableEditPrefsMenuItem,
        addPage: addPage,
        updatePage: updatePage,
        movePage: movePage,
        closePageDialog: closePageDialog
    };    
})();
