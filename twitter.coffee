_Twitter = Npm.require 'twitter'

_Twitter::__request = (method, path, params, callback) ->
    base = 'rest'
    stream = false

    # Set the callback if no params are passed
    if typeof params is 'function'
        callback = params
        params = {}

    # Set API base
    if typeof params.base isnt 'undefined'
        base = params.base
        delete params.base

    # Stream?
    if base.match /stream/
        stream = true

    # Build the options to pass to our custom request object
    options =
        method: method.toLowerCase() # Request method - get || post
        url: @__buildEndpoint(path, base) # Generate url

    # Pass url parameters if get
    if method is 'get'
        options.qs = params

    # Pass form data if post
    if method is 'post'
        if @options.request_options.json
            options.body = params
        else
            formKey = 'form'

            if typeof params.media isnt 'undefined'
                formKey = 'formData'
            options[formKey] = params

    @request options, (error, response, data) ->
        if error?
            callback error, data, response
        else
            if typeof data isnt 'object'
                try
                    data = JSON.parse data
                catch parseError
                    callback new Error('Status Code: ' + response.statusCode), data, response
                    return
            if typeof data.error isnt 'undefined'
                callback data.error, data, response
            else if typeof data.errors isnt 'undefined'
                callback data.errors, data, response
            else if response.statusCode isnt 200
                callback new Error('Status Code: ' + response.statusCode), data, response
            else
                callback null, data, response
            return
    return

class Parser
    constructor: (@stream) ->

    on: (event, listener) ->
        @stream.on event, Meteor.bindEnvironment listener, "twitter stream (#{event})"
        return

class Twitter
    constructor: (opts) ->
        @client = new _Twitter opts

    _request: (method, url, params, callback) ->
        if typeof params is 'function'
            callback = params
            params = {}
        @client[method] url, params, (error, data, response) ->
            if error?
                callback error, data
            else
                callback null, data
            return
        return

    _get: (url, params, callback) ->
        @_request 'get', url, params, callback
        return

    get: (url, params) ->
        Meteor.wrapAsync(@_get, this) url, params

    _post: (url, params, callback) ->
        @_request 'post', url, params, callback
        return

    post: (url, params) ->
        Meteor.wrapAsync(@_post, this) url, params

    stream: (method, params, callback) ->
        if typeof params is 'function'
            callback = params
            params = {}
        @client.stream method, params, (stream) ->
            callback new Parser stream
            return
        return
