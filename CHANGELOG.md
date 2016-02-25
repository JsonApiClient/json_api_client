# Changelog

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
