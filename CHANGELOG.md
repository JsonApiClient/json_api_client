# Changelog

## Unreleased

## v1.5.1

- [#236](https://github.com/chingor13/json_api_client/pull/236) - Escape nested route keys

## v1.5.0

- [#239](https://github.com/chingor13/json_api_client/pull/239) - Configurable pagination params
- [#238](https://github.com/chingor13/json_api_client/pull/238) - Parse links after creating a resource
- [#230](https://github.com/chingor13/json_api_client/pull/230) - Unformat error source parameters via key formatter.
- [#228](https://github.com/chingor13/json_api_client/pull/228) - All schema types to be pluggable.

## v1.4.0
- [#217](https://github.com/chingor13/json_api_client/pull/217) - Add decimal (BigDecimal) as a serializing type
- [#222](https://github.com/chingor13/json_api_client/pull/222) - Add `last` method for a resource and scope (similar to `first`)

## v1.3.0
- [#208](https://github.com/chingor13/json_api_client/pull/208) - Fall back to error.detail for the error message [#196](https://github.com/chingor13/json_api_client/issues/196)
- [#206](https://github.com/chingor13/json_api_client/pull/206) - Autoload `JsonApiClient::VERSION` constant
- [#205](https://github.com/chingor13/json_api_client/pull/205) - `RelationshipLinker` now correctly uses the resource class' `KeyFormatter`
- [#203](https://github.com/chingor13/json_api_client/pull/203) - No longer raise `KeyError` when trying to paginate to a page that doesn't exist. Return nil instead

## v1.2.0
- [#201](https://github.com/chingor13/json_api_client/pull/201) - Configurable key and path formatter on a per-resource basis
- [#190](https://github.com/chingor13/json_api_client/pull/190) - Allow hook for overriding the `total_entries` method on the default paginator
- [#199](https://github.com/chingor13/json_api_client/pull/199) - Clean up test warnings
- [#198](https://github.com/chingor13/json_api_client/pull/198) - Clean up test warnings
- [#187](https://github.com/chingor13/json_api_client/pull/187) - README update and cleanup around `select` for `Query::Builder`
- [#191](https://github.com/chingor13/json_api_client/pull/191) - Don't explode when parsing `"data": null`
- [#183](https://github.com/chingor13/json_api_client/pull/183) - `select` for `Query::Builder` can accept strings, symbols, arrays
- [#181](https://github.com/chingor13/json_api_client/pull/181) - Handle HTTP 409 - Conflict error

## v1.1.1
- [#163](https://github.com/chingor13/json_api_client/pull/163) - Handle faraday connection options (proxy, ssl, etc)
- [#165](https://github.com/chingor13/json_api_client/pull/165) - Handle null data returned for associated resources

## v1.1.0
- [#159](https://github.com/chingor13/json_api_client/pull/159) - Alias update method as update_attributes
- [#160](https://github.com/chingor13/json_api_client/pull/160) - Add .with_params to add arbitrary query params on find
- [#161](https://github.com/chingor13/json_api_client/pull/161) - Fixes pagination issues: [#142](https://github.com/chingor13/json_api_client/issues/142) and [#150](https://github.com/chingor13/json_api_client/issues/150)
- [#162](https://github.com/chingor13/json_api_client/pull/162) - Fix faraday version dependency to ~> 0.9

## v1.0.2
- [#152](https://github.com/chingor13/json_api_client/pull/152) - Pass rebuild flag to _build_connection
- [#140](https://github.com/chingor13/json_api_client/pull/140) - Handle 401 Not Authorized responses
- [#137](https://github.com/chingor13/json_api_client/pull/137) - Support for validation contexts

## v1.0.1
- [#135](https://github.com/chingor13/json_api_client/pull/135) - Added support for common boolean typecasting
- [#119](https://github.com/chingor13/json_api_client/pull/119) - property should not add default value if default is nil
- [#129](https://github.com/chingor13/json_api_client/pull/129) - Resource save does not update anything but attributes
- [#131](https://github.com/chingor13/json_api_client/pull/131) - Handle error values explicitly set to null.

## v1.0.0
- initial release for [1.0 spec](http://jsonapi.org/format/1.0/)
