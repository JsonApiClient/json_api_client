# Changelog

## Unreleased

## 1.16.1

- [#361](https://github.com/JsonApiClient/json_api_client/pull/361) - Call super from inherited method so that it will execute parent classes' implementations

## 1.16.0

- [#359](https://github.com/JsonApiClient/json_api_client/pull/359) - Support gzip content encoding

## 1.15.0

- [#346](https://github.com/JsonApiClient/json_api_client/pull/346) - add the option to have immutable resources
- [#357](https://github.com/JsonApiClient/json_api_client/pull/357) - fix missing constant formatter

## 1.14.1

- [#353](https://github.com/JsonApiClient/json_api_client/pull/353) - fix to support deserializing resources with relationships without those related resources being included in the response (issue [#352](https://github.com/JsonApiClient/json_api_client/issues/352)).

## 1.14.0

- [#338](https://github.com/JsonApiClient/json_api_client/pull/338) - implement hash and eql? for builder class
- [#351](https://github.com/JsonApiClient/json_api_client/pull/351) - Remove rudimental `last_result_set` relationship from serializer

## 1.13.0

- [#348](https://github.com/JsonApiClient/json_api_client/pull/348) - add NestedParamPaginator to address inconsistency in handling of pagination query string params (issue [#347](https://github.com/JsonApiClient/json_api_client/issues/347)).

## 1.12.2

- [#350](https://github.com/JsonApiClient/json_api_client/pull/350) - fix resource including with blank `relationships` response data

## 1.12.1

- [#349](https://github.com/JsonApiClient/json_api_client/pull/349) - fix resource including for STI objects

## 1.12.0

- [#345](https://github.com/JsonApiClient/json_api_client/pull/345) - track the real HTTP reason of ApiErrors

## 1.11.0

- [#344](https://github.com/JsonApiClient/json_api_client/pull/344) - introduce safe singular resource fetching with `raise_on_blank_find_param` resource setting

## 1.10.0

- [#335](https://github.com/JsonApiClient/json_api_client/pull/335) - access to assigned relationship

## 1.9.0

- [#328](https://github.com/JsonApiClient/json_api_client/pull/328) - allow custom type for models

- [#326](https://github.com/JsonApiClient/json_api_client/pull/326) - correct changes after initialize resource
  * remove type from changes on initialize
  * ensure that query builder doesn't propagate query values to resource attributes via #build method

- [#324](https://github.com/JsonApiClient/json_api_client/pull/324) - add possibility to override status handling
  * add status_handlers to JsonApiClient::Resource.connection_options

- [#330](https://github.com/JsonApiClient/json_api_client/pull/330) - deletion use overridden primary key

## 1.8.0

- [#316](https://github.com/JsonApiClient/json_api_client/pull/316) - Allow custom error messages

- [#305](https://github.com/JsonApiClient/json_api_client/pull/305) - optional search relationship data in result set

## 1.7.0

- [#320](https://github.com/JsonApiClient/json_api_client/pull/320) - fix passing relationships on create
  * fix relationships passing to `new` and `create` methods
  * fix false positive tests on create
  * refactor tests on create/update to prevent false same positive tests in future

- [#315](https://github.com/JsonApiClient/json_api_client/pull/315) - add shallow_path feature to belongs_to
 * add `shallow_path` options to belongs_to to use model w/ and w/o nesting in parent resource

## v1.6.4
- [#314](https://github.com/JsonApiClient/json_api_client/pull/314) - Mimic ActiveRecord behavior when destroying a resource:
  * Add `destroyed?` method
  * Do not clear resource attributes
  * Return `false` on `persisted?` after being destroyed
  * Return `false` on `new_record?` after being destroyed

## v1.6.3

- [#312](https://githup.com/JsonApiClient/json_api_client/pull/312) - Don't raise on `422`

## v1.6.2

- [#311](https://githup.com/JsonApiClient/json_api_client/pull/311) - Raise JsonApiClient::Errors::ClientError for unhandled 4xx responses

## v1.6.1

- [#297](https://githup.com/JsonApiClient/json_api_client/pull/297) - Fix test_helper
- [#298](https://githup.com/JsonApiClient/json_api_client/pull/298) - README update: arguments for custom connections run method
- [#306](https://githup.com/JsonApiClient/json_api_client/pull/306) - README update: pagination override examples
- [#307](https://githup.com/JsonApiClient/json_api_client/pull/307) - Symbolize params keys on model initialize
- [#304](https://githup.com/JsonApiClient/json_api_client/pull/304) - Optional add default to changes
- [#300](https://githup.com/JsonApiClient/json_api_client/pull/300) - Define methods for properties and associations getter/setter

## v1.6.0

- [#281](https://github.com/JsonApiClient/json_api_client/pull/281) - Optimize dynamic attribute deref
- [#280](https://github.com/JsonApiClient/json_api_client/pull/280) - Fix custom headers inheritance
- [#287](https://github.com/JsonApiClient/json_api_client/pull/287) - Allow pagination params to be `nil`
- [#284](https://github.com/JsonApiClient/json_api_client/pull/284) - Fix filter to not filter out `[]` values
- [#285](https://github.com/JsonApiClient/json_api_client/pull/285) - Add include params for create/update
- [#293](https://github.com/JsonApiClient/json_api_client/pull/293) - Fix side-effects in scopes

## v1.5.3

- [#266](https://github.com/chingor13/json_api_client/pull/266) - Fix default attributes being overridden
- [#267](https://github.com/chingor13/json_api_client/pull/267) - Fix custom pagination params
- [#271](https://github.com/chingor13/json_api_client/pull/271) - Fix assert_nil warnings
- [#275](https://github.com/chingor13/json_api_client/pull/275) - Add error messages when destroy fails
- [#277](https://github.com/chingor13/json_api_client/pull/277) - Correct handling of error source/pointer

## v1.5.2

- [#264](https://github.com/chingor13/json_api_client/pull/264) - Enable sparse fieldsets for nested models
- [#263](https://github.com/chingor13/json_api_client/pull/263) - Fix initializing resource including relationships
- [#260](https://github.com/chingor13/json_api_client/pull/260) - Use formatter for belongs_to keys

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
