/**
 * Blackthorn.io, Inc CONFIDENTIAL
 * __________________________________
 * 
 *  [2022] Blackthorn.io, Inc
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Blackthorn.io, Inc and its suppliers,
 * if any. The intellectual and technical concepts contained
 * herein are proprietary to Blackthorn.io, Inc
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Blackthorn.io, Inc.
 *
 * 
 * A library of methods used to construct HTTP requests.
 *
 *
**/
public with sharing class SCH_RequestBuilder {
    public SCH_Schedule_Config__c config = SCH_BtBaseUtils.getCustomSettings();
    public String apiToken; // account number
    public String apiKey; // api key

    private String BASE_URL;
    /**
     *  Constructor
     *
     *
     **/
    public SCH_RequestBuilder() {
        // setup test instance for test cases.
        String uri = EncodingUtil.urlEncode(config.URL__c, 'UTF-8');
        String apiVersion = EncodingUtil.urlEncode(config.API_Version__c, 'UTF-8');

        BASE_URL = String.format('https://{0}/{1}', new List<String> {
            uri,
            apiversion
        });
    }
    /**
     *  @param  path    - the url path
     *  @param  qParams - a map of query string parameters in the form of KEY => VALUE
     *  @return a SCH_ResponseWrapper 
     *
     *  Construct an HTTP GET request with the given path and query parameters. Wrap and 
     *  return the HTTP response.
     *
     **/
    public SCH_ResponseWrapper get(String path, Map<String, String> qParams) {
        HttpRequest request = constructGet(path, qParams);
        HttpResponse response;

        try {
            response = new Http().send(request);
        } catch (System.Exception e) {
            throw new SCH_Exception(e.getMessage(), null);
        }

        return wrap(response);
    }

    /**
     *  @param  path    - the url path
     *  @param  bParams - a map of body parameters in the form of KEY => VALUE
     *  @return a SCH_ResponseWrapper 
     *
     *  Constructs an HTTP POST request with the given path and body parameters.  Wrap and 
     *  return the HTTP response.
     *
     **/
    public SCH_ResponseWrapper post(String path, Map<String, String> bParams) {
        HttpRequest request = constructPost(path, bParams);
        HttpResponse response;
        try {
            System.debug(request.getBody());
            response = new Http().send(request);
            System.debug(response);
        } catch (System.Exception e) {
            System.debug('>exception ' + e);
            throw new SCH_Exception(e.getMessage(), null);
        }

        return wrap(response);
    }

    /**
     *  @param  path    - the url path
     *  @param  bParams - a map of body parameters in the form of KEY => VALUE
     *  @return a SCH_ResponseWrapper 
     *
     *  Constructs an HTTP PUT request with the given path and body parameters.  Wrap and 
     *  return the HTTP response.
     *
     **/
    public SCH_ResponseWrapper put(String path, Map<String, String> bParams) {
        HttpRequest request = constructPut(path, bParams);
        HttpResponse response;
        try {
            System.debug(request.getBody());
            response = new Http().send(request);
        } catch (System.Exception e) {
            throw new SCH_Exception(e.getMessage(), null);
        }

        return wrap(response);
    }

    /**
     *  @param  path    - the url path
     *  @param  bParams - a map of body  parameters in the form of KEY => VALUE
     *  @return a SCH_ResponseWrapper 
     *
     *  Constructs an HTTP DELETE request with the given path and body parameters.  Wrap and 
     *  return the HTTP response.
     *
     **/
    public SCH_ResponseWrapper del(String path, Map<String, String> bParams) {
        HttpRequest request = constructDelete(path, bParams);
        HttpResponse response;

        try {
            response = new Http().send(request);
        } catch (System.Exception e) {
            throw new SCH_Exception(e.getMessage(), null);
        }

        return wrap(response);
    }

    /**
     *  @param  apiToken - the api token to use in the requests.
     *
     **/
    public void setApiToken(String apiToken) {
        this.apiToken = apiToken;
    }

    /**
     *  @param  apiKey - the api key to use in the requests.
     *
     **/
    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    /**
     *  @param  path    - the URL path
     *  @param  qParams - a map of query string parameters in the form of KEY => VALUE
     *  @return an HttpRequest
     *
     *  Build and return an HTTP GET request with the given path and query parameters.
     *
     **/
    private HttpRequest constructGet(String path, Map<String, String> qParams) {
        String endpoint = BASE_URL + path;
        endpoint += qParams.size() > 0 ? '?' : '';

        for (String key: qParams.keySet()) {
            if (qParams.get(key) != null) {
                endpoint += (key + '=' + qParams.get(key) + '&');
            }
        }

        endpoint = endpoint.removeEnd('&');

        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request.setTimeout(120000);
        request.setHeader('Authorization', getAuthHeader());

        return request;
    }

    /**
     *  @param  path    - the URL path
     *  @param  qParams - a map of body parameters in the form of KEY => VALUE
     *  @return an HttpRequest
     *
     *  Build and return an HTTP POST request with the given path and body parameters.
     *
     **/
    private HttpRequest constructPost(String path, Map<String, String> bParams) {
        String endpoint = BASE_URL + path;

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(getJsonStringFromMap(bParams));
        request.setTimeout(120000);
        request.setHeader('Authorization', getAuthHeader());

        return request;
    }

    /**
     *  @param  path    - the URL path
     *  @param  qParams - a map of body parameters in the form of KEY => VALUE
     *  @return an HttpRequest
     *
     *  Build and return an HTTP POST request with the given path and body parameters.
     *
     **/
    private HttpRequest constructPut(String path, Map<String, String> bParams) {
        String endpoint = BASE_URL + path;

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(endpoint);
        request.setBody(getJsonStringFromMap(bParams));
        request.setTimeout(120000);
        request.setHeader('Authorization', getAuthHeader());

        return request;
    }

    /**
     *  @param  path    - the URL path
     *  @param  qParams - a map of body parameters in the form of KEY => VALUE
     *  @return an HttpRequest
     *
     *  Build and return an HTTP DELETE request with the given path and body parameters.
     *
     **/
    private HttpRequest constructDelete(String path, Map<String, String> bParams) {
        String endpoint = BASE_URL + path;

        HttpRequest request = new HttpRequest();
        request.setMethod('DELETE');
        request.setEndpoint(endpoint);
        request.setBody(getJsonStringFromMap(bParams));
        request.setTimeout(120000);
        request.setHeader('Authorization', getAuthHeader());

        return request;
    }

    /**
     *  @param  response - an HTTP Response
     *  @return a SCH_ResponseWrapper
     *
     *  Wrap the Http response in a wrapper class.  If the server returns an non-success status code an 
     *  error is thrown.
     *
     **/
    private SCH_ResponseWrapper wrap(HttpResponse response) {
        Integer status = response.getStatusCode();
        System.debug(response.getBody());
        if (status<300)
            return new SCH_ResponseWrapper(response.getBody());
        else if (status<500)
            throw new SCH_Exception(response.getBody(), null);
        else
            throw new SCH_Exception('Unexpected server error.', null);
    }

    /**
     *  @param  m - a map of parameters
     *
     *  Converts a parameter map to a JSON string.
     *
     **/
    public String getJsonStringFromMap(Map<String, String> m) {
        String body = '';
        if(!m.containsKey('body')){
            if (m.containsKey('direct_request_body')) {
                return m.get('direct_request_body');
            } else if (m.containsKey('schedule_body')) {
                return m.get('schedule_body');
            }
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
    
            for (String key: m.keySet()) {
                // deserialize certain pre-serialized strings then use the writeObjectField method.
                // otherwise, a double serialization occurs and causes parsing errors in the Blackthorn Scheduler API.
                if (key == 'to_number' || key == 'to_numbers') {
                    List<String> to_numbers = (List<String>) JSON.deserialize(m.get(key), List<String>.class);
                    gen.writeObjectField(key, to_numbers);
                }else if (key == 'recipient') {
                    gen.writeObjectField(key, (Object)JSON.deserializeUntyped(m.get(key)));
                } else {
                    gen.writeStringField(key, String.escapeSingleQuotes(m.get(key).replaceAll('\r', '')));
                }
            }
    
            gen.writeEndObject();
            gen.close();

            body = gen.getAsString();
        }else{
            body = m.get('body');
        }
        system.debug('========================= body : '+body);
        return body;
    }

    /**
     *  Constructs the Authentication Header needed in a request to Twilio.  The result is assigned to an
     *  instance variable.
     *
     **/
    private String getAuthHeader() {
        String auth = apiToken + ':' + apiKey;
        Blob headerValue = Blob.valueOf(auth);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authHeader;
    }
}