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
package org.apache.rave.opensocial.model;

import org.apache.rave.persistence.BasicEntity;

import javax.persistence.*;
import java.util.Map;

@Entity
@Table(name = "application_data")
@NamedQueries(value = {
        @NamedQuery(name = ApplicationData.FIND_BY_USER_IDS_AND_APP_ID, query = "select a from ApplicationData a " +
                "where a.userId IN :" + ApplicationData.USER_IDS_PARAM + " AND a.appUrl = :" + ApplicationData.APP_URL_PARAM),
        @NamedQuery(name = ApplicationData.FIND_BY_USER_ID_AND_APP_ID, query = "select a from ApplicationData a " +
                "where a.userId = :" + ApplicationData.USER_ID_PARAM + " AND a.appUrl = :" + ApplicationData.APP_URL_PARAM)
})
public class ApplicationData implements BasicEntity {
    public static final String FIND_BY_USER_IDS_AND_APP_ID = "ApplicationData.findByUserIdsAndAppId";
    public static final String FIND_BY_USER_ID_AND_APP_ID = "ApplicationData.findByUserIdAndAppId";

    public static final String USER_IDS_PARAM = "userIds";
    public static final String USER_ID_PARAM = "userId";
    public static final String APP_URL_PARAM = "appUrl";

    /**
     * The internal object ID used for references to this object.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "applicationDataIdGenerator")
    @TableGenerator(name = "applicationDataIdGenerator", table = "RAVE_SHINDIG_SEQUENCES", pkColumnName = "SEQ_NAME",
            valueColumnName = "SEQ_COUNT", pkColumnValue = "application_data", allocationSize = 1, initialValue = 1)
    @Column(name = "entity_id")
    private Long entityId;

    @Column(name = "user_id")
    private String userId;

    @Column(name = "app_url")
    private String appUrl;

    @Transient
    private Map<String, String> data;

    public ApplicationData() {
    }

    public ApplicationData(Long entityId, String userId, String appUrl, Map<String, String> data) {
        this.entityId = entityId;
        this.userId = userId;
        this.appUrl = appUrl;
        this.data = data;
    }

    public Long getEntityId() {
        return entityId;
    }

    public void setEntityId(Long entityId) {
        this.entityId = entityId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getAppUrl() {
        return appUrl;
    }

    public void setAppUrl(String appUrl) {
        this.appUrl = appUrl;
    }

    public Map<String, String> getData() {
        return data;
    }

    public void setData(Map<String, String> data) {
        this.data = data;
    }
}
