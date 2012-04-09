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

package org.apache.rave.provider.opensocial.service.impl;

import org.apache.commons.io.FileUtils;
import org.apache.rave.portal.model.*;
import org.apache.rave.portal.service.UserService;
import org.apache.rave.provider.opensocial.exception.SecurityTokenException;
import org.apache.rave.provider.opensocial.service.SecurityTokenService;
import org.apache.shindig.auth.AbstractSecurityToken;
import org.apache.shindig.auth.BlobCrypterSecurityToken;
import org.apache.shindig.auth.SecurityToken;
import org.apache.shindig.common.crypto.BasicBlobCrypter;
import org.apache.shindig.common.crypto.BlobCrypter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Service
public class EncryptedBlobSecurityTokenService implements SecurityTokenService {
    private static Logger logger = LoggerFactory.getLogger(EncryptedBlobSecurityTokenService.class);

    public static final String EMBEDDED_KEY_PREFIX = "embedded:";
    public static final String CLASSPATH_KEY_PREFIX = "classpath:";

    private UserService userService;
    private String container;
    private String domain;

    private BlobCrypter blobCrypter;

    @Autowired
    public EncryptedBlobSecurityTokenService(UserService userService,
                                             @Value("${portal.opensocial_security.container}") String container,
                                             @Value("${portal.opensocial_security.domain}") String domain,
                                             @Value("${portal.opensocial_security.encryptionkey}") String encryptionKey) {
        this.userService = userService;
        this.container = container;
        this.domain = domain;

        if (encryptionKey.startsWith(EMBEDDED_KEY_PREFIX)) {
            this.blobCrypter = new BasicBlobCrypter(encryptionKey.substring(EMBEDDED_KEY_PREFIX.length()));
        } else if (encryptionKey.startsWith(CLASSPATH_KEY_PREFIX)) {
            try {
                File file = new ClassPathResource(encryptionKey.substring(CLASSPATH_KEY_PREFIX.length())).getFile();
                this.blobCrypter = new BasicBlobCrypter(FileUtils.readFileToString(file, "UTF-8"));
            } catch (IOException e) {
                throw new SecurityException("Unable to load encryption key from classpath resource: " + encryptionKey);
            }
        } else {
            try {
                File file = new File(encryptionKey);
                this.blobCrypter = new BasicBlobCrypter(FileUtils.readFileToString(file, "UTF-8"));
            } catch (IOException e) {
                throw new SecurityException("Unable to load encryption key from file: " + encryptionKey);
            }
        }
    }

    @Override
    public SecurityToken getSecurityToken(RegionWidget regionWidget) throws SecurityTokenException {
        return this.getBlobCrypterSecurityToken(regionWidget);
    }

    @Override
    public String getEncryptedSecurityToken(RegionWidget regionWidget) throws SecurityTokenException {
        String encryptedToken = null;

        try {
            BlobCrypterSecurityToken securityToken = this.getBlobCrypterSecurityToken(regionWidget);
            encryptedToken = this.encryptSecurityToken(securityToken);
        } catch (Exception e) {
            throw new SecurityTokenException("Error creating security token from regionWidget", e);
        }

        return encryptedToken;
    }

    @Override
    public SecurityToken decryptSecurityToken(String encryptedSecurityToken) throws SecurityTokenException {
        SecurityToken securityToken;

        try {
            if (logger.isTraceEnabled()) {
                logger.trace("Decrypting security token: " + encryptedSecurityToken);
            }

            //Remove the header container string and :
            encryptedSecurityToken = encryptedSecurityToken.substring((container + ":").length());

            //Decrypt
            Map<String, String> values = blobCrypter.unwrap(encryptedSecurityToken);
            securityToken = new BlobCrypterSecurityToken(container, domain, null, values);
        } catch (Exception e) {
            throw new SecurityTokenException("Error creating security token from encrypted string: " +
                    encryptedSecurityToken, e);
        }

        return securityToken;
    }

    @Override
    public String refreshEncryptedSecurityToken(String encryptedSecurityToken) throws SecurityTokenException {
        //Decrypt the current token
        SecurityToken securityToken = this.decryptSecurityToken(encryptedSecurityToken);

        //Make sure the person is authorized to refresh this token
        String userId = String.valueOf(userService.getAuthenticatedUser().getEntityId());
        if (!securityToken.getViewerId().equalsIgnoreCase(userId)) {
            throw new SecurityTokenException("Illegal attempt by user " + userId +
                    " to refresh security token with a viewerId of " + securityToken.getViewerId());
        }

        //Create a new RegionWidget instance from it so we can use it to generate a new encrypted token
        RegionWidget regionWidget = new RegionWidget(securityToken.getModuleId(),
                new Widget(-1L, securityToken.getAppUrl()),
                new Region(-1L, new Page(-1L, new User(Long.valueOf(securityToken.getOwnerId()))), -1));

        //Create and return the newly encrypted token
        return getEncryptedSecurityToken(regionWidget);
    }

    private BlobCrypterSecurityToken getBlobCrypterSecurityToken(RegionWidget regionWidget)
            throws SecurityTokenException {
        User user = userService.getAuthenticatedUser();

        Map<String, String> values = new HashMap<String, String>();
        values.put(AbstractSecurityToken.Keys.APP_URL.getKey(), regionWidget.getWidget().getUrl());
        values.put(AbstractSecurityToken.Keys.MODULE_ID.getKey(), String.valueOf(regionWidget.getEntityId()));
        values.put(AbstractSecurityToken.Keys.OWNER.getKey(),
                String.valueOf(regionWidget.getRegion().getPage().getOwner().getEntityId()));
        values.put(AbstractSecurityToken.Keys.VIEWER.getKey(), String.valueOf(user.getEntityId()));
        values.put(AbstractSecurityToken.Keys.TRUSTED_JSON.getKey(), "");

        BlobCrypterSecurityToken securityToken = new BlobCrypterSecurityToken(container, domain, null, values);

        if (logger.isTraceEnabled()) {
            logger.trace("Token created for regionWidget " + regionWidget.toString() + " and user " + user.toString());
        }

        return securityToken;
    }

    private String encryptSecurityToken(BlobCrypterSecurityToken securityToken) throws SecurityTokenException {
        String encryptedToken = null;

        try {
            encryptedToken = container + ":" + blobCrypter.wrap(securityToken.toMap());
            if (logger.isTraceEnabled()) {
                logger.trace("Encrypted token created from security token: " + securityToken.toString() +
                        " -- encrypted token is: " + encryptedToken);
            }
        } catch (Exception e) {
            throw new SecurityTokenException("Error creating security token from person gadget", e);
        }

        return encryptedToken;
    }
}
