/// Phase 35: API Documentation & SDK Generation テスト
///
/// 30個の包括的なテストケース

import 'package:test/test.dart';
import 'package:project_040/models/api_documentation_models.dart';
import 'package:project_040/services/api_documentation_service.dart';

void main() {
  group('Phase 35: API Documentation Tests', () {
    late ApiDocumentationManager manager;

    setUp(() {
      manager = ApiDocumentationManager();
    });

    // HttpMethod Tests (2 tests)
    group('HttpMethod Enum', () {
      test('1. HttpMethod enum values', () {
        expect(HttpMethod.get.value, equals('GET'));
        expect(HttpMethod.post.value, equals('POST'));
        expect(HttpMethod.put.value, equals('PUT'));
        expect(HttpMethod.patch.value, equals('PATCH'));
        expect(HttpMethod.delete.value, equals('DELETE'));
        expect(HttpMethod.values.length, equals(7));
      });

      test('2. HttpMethod lowercase value', () {
        expect(HttpMethod.get.value.toLowerCase(), equals('get'));
        expect(HttpMethod.post.value.toLowerCase(), equals('post'));
      });
    });

    // DataType Tests (2 tests)
    group('DataType Enum', () {
      test('3. DataType enum values', () {
        expect(DataType.string.value, equals('string'));
        expect(DataType.number.value, equals('number'));
        expect(DataType.integer.value, equals('integer'));
        expect(DataType.boolean.value, equals('boolean'));
        expect(DataType.array.value, equals('array'));
        expect(DataType.object.value, equals('object'));
        expect(DataType.file.value, equals('file'));
      });

      test('4. DataType enum count', () {
        expect(DataType.values.length, equals(7));
      });
    });

    // ApiParameter Tests (4 tests)
    group('API Parameter Definition', () {
      test('5. Create parameter with validation', () {
        final param = ApiParameter(
          parameterId: 'param_1',
          name: 'userId',
          description: 'User identifier',
          dataType: DataType.string,
          location: ParameterLocation.path,
          required: true,
          pattern: r'^\d+$',
          minLength: 1,
          maxLength: 50,
          createdAt: DateTime.now(),
        );

        expect(param.name, equals('userId'));
        expect(param.required, isTrue);
        expect(param.pattern, equals(r'^\d+$'));
      });

      test('6. Parameter with enum values', () {
        final param = ApiParameter(
          parameterId: 'param_2',
          name: 'status',
          description: 'Job status',
          dataType: DataType.string,
          location: ParameterLocation.query,
          enumValues: ['pending', 'running', 'completed', 'failed'],
          createdAt: DateTime.now(),
        );

        expect(param.enumValues, contains('completed'));
        expect(param.enumValues!.length, equals(4));
      });

      test('7. Parameter location types', () {
        expect(ParameterLocation.path.value, equals('path'));
        expect(ParameterLocation.query.value, equals('query'));
        expect(ParameterLocation.header.value, equals('header'));
        expect(ParameterLocation.body.value, equals('body'));
        expect(ParameterLocation.formData.value, equals('formData'));
      });

      test('8. Parameter with default value', () {
        final param = ApiParameter(
          parameterId: 'param_3',
          name: 'limit',
          description: 'Result limit',
          dataType: DataType.integer,
          location: ParameterLocation.query,
          defaultValue: '10',
          createdAt: DateTime.now(),
        );

        expect(param.defaultValue, equals('10'));
      });
    });

    // ApiResponse Tests (3 tests)
    group('API Response Definition', () {
      test('9. Create successful response', () {
        final response = ApiResponse(
          responseId: 'resp_1',
          statusCode: 200,
          description: 'Successful response',
          schema: {'type': 'object', 'properties': {}},
          contentType: 'application/json',
          createdAt: DateTime.now(),
        );

        expect(response.statusCode, equals(200));
        expect(response.contentType, equals('application/json'));
      });

      test('10. Create error response', () {
        final response = ApiResponse(
          responseId: 'resp_2',
          statusCode: 400,
          description: 'Bad Request',
          schema: {'type': 'object'},
          createdAt: DateTime.now(),
        );

        expect(response.statusCode, equals(400));
      });

      test('11. Response with headers', () {
        final response = ApiResponse(
          responseId: 'resp_3',
          statusCode: 200,
          description: 'Success',
          schema: {},
          headers: {
            'X-Total-Count': 'integer',
            'X-Page-Number': 'integer',
          },
          createdAt: DateTime.now(),
        );

        expect(response.headers, isNotNull);
        expect(response.headers!['X-Total-Count'], equals('integer'));
      });
    });

    // ApiEndpoint Tests (4 tests)
    group('API Endpoint Definition', () {
      test('12. Create GET endpoint', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_1',
          path: '/jobs',
          method: HttpMethod.get,
          summary: 'List jobs',
          description: 'Get list of all jobs',
          tags: ['jobs'],
          responses: [
            ApiResponse(
              responseId: 'resp_1',
              statusCode: 200,
              description: 'Success',
              schema: {'type': 'array'},
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(endpoint.path, equals('/jobs'));
        expect(endpoint.method, equals(HttpMethod.get));
        expect(endpoint.tags, contains('jobs'));
      });

      test('13. Create POST endpoint with parameters', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_2',
          path: '/jobs',
          method: HttpMethod.post,
          summary: 'Create job',
          description: 'Create new job',
          parameters: [
            ApiParameter(
              parameterId: 'param_1',
              name: 'jobType',
              description: 'Job type',
              dataType: DataType.string,
              location: ParameterLocation.body,
              required: true,
              createdAt: DateTime.now(),
            ),
          ],
          responses: [
            ApiResponse(
              responseId: 'resp_1',
              statusCode: 201,
              description: 'Created',
              schema: {'type': 'object'},
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(endpoint.method, equals(HttpMethod.post));
        expect(endpoint.parameters.length, equals(1));
      });

      test('14. Deprecated endpoint', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_3',
          path: '/legacy/jobs',
          method: HttpMethod.get,
          summary: 'List jobs (deprecated)',
          description: 'Use /jobs instead',
          deprecated: true,
          responses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(endpoint.deprecated, isTrue);
      });

      test('15. Endpoint operationIdOrDefault', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_4',
          path: '/jobs/{id}',
          method: HttpMethod.get,
          summary: 'Get job',
          description: 'Get job by id',
          responses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final operationId = endpoint.operationIdOrDefault;
        expect(operationId, contains('GET'));
      });
    });

    // ApiResource Tests (2 tests)
    group('API Resource Definition', () {
      test('16. Create API resource', () {
        final resource = ApiResource(
          resourceId: 'res_1',
          name: 'Job',
          description: 'Job resource',
          schema: {
            'type': 'object',
            'properties': {
              'jobId': {'type': 'string'},
              'status': {'type': 'string'},
              'createdAt': {'type': 'string', 'format': 'date-time'},
            },
          },
          createdAt: DateTime.now(),
        );

        expect(resource.name, equals('Job'));
        expect(resource.schema['type'], equals('object'));
      });

      test('17. Resource with examples', () {
        final resource = ApiResource(
          resourceId: 'res_2',
          name: 'User',
          description: 'User resource',
          schema: {},
          examples: [
            '{"userId": "1", "name": "Alice"}',
            '{"userId": "2", "name": "Bob"}',
          ],
          createdAt: DateTime.now(),
        );

        expect(resource.examples, isNotNull);
        expect(resource.examples!.length, equals(2));
      });
    });

    // ApiSpecification Tests (4 tests)
    group('API Specification', () {
      test('18. Create API specification', () {
        final spec = ApiSpecification(
          specId: 'spec_1',
          title: 'Job API',
          description: 'API for job management',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(spec.title, equals('Job API'));
        expect(spec.version, equals('1.0.0'));
      });

      test('19. Specification with endpoints and resources', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_1',
          path: '/jobs',
          method: HttpMethod.get,
          summary: 'List jobs',
          description: 'Get jobs',
          responses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final resource = ApiResource(
          resourceId: 'res_1',
          name: 'Job',
          description: 'Job',
          schema: {},
          createdAt: DateTime.now(),
        );

        final spec = ApiSpecification(
          specId: 'spec_2',
          title: 'API',
          description: 'Desc',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [endpoint],
          resources: {'Job': resource},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(spec.endpoints.length, equals(1));
        expect(spec.resources.length, equals(1));
      });

      test('20. Specification contact information', () {
        final spec = ApiSpecification(
          specId: 'spec_3',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          contactName: 'API Support',
          contactEmail: 'support@example.com',
          contactUrl: 'https://example.com/support',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(spec.contactName, equals('API Support'));
        expect(spec.contactEmail, equals('support@example.com'));
      });

      test('21. OpenAPI export', () {
        final spec = ApiSpecification(
          specId: 'spec_4',
          title: 'Test API',
          description: 'Test',
          version: '1.0.0',
          baseUrl: 'https://api.test.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final openApi = spec.toOpenApiSpec();
        expect(openApi['openapi'], equals('3.0.0'));
        expect(openApi['info']['title'], equals('Test API'));
        expect(openApi['servers'], isNotEmpty);
      });
    });

    // SDK Generation Tests (4 tests)
    group('SDK Generation', () {
      test('22. SDK generation config', () {
        final config = SdkGenerationConfig(
          configId: 'config_1',
          language: 'dart',
          packageName: 'job_api_client',
          packageVersion: '1.0.0',
          generateModels: true,
          generateClient: true,
          generateTests: true,
          generateDocs: true,
          createdAt: DateTime.now(),
        );

        expect(config.language, equals('dart'));
        expect(config.packageName, equals('job_api_client'));
        expect(config.generateModels, isTrue);
      });

      test('23. Supported languages', () {
        final languages = manager.supportedLanguages();
        expect(languages, contains('dart'));
        expect(languages, contains('typescript'));
        expect(languages, contains('python'));
        expect(languages.length, greaterThan(0));
      });

      test('24. SDK generation result success', () async {
        final spec = ApiSpecification(
          specId: 'spec_1',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final config = SdkGenerationConfig(
          configId: 'config_1',
          language: 'dart',
          packageName: 'test_sdk',
          packageVersion: '1.0.0',
          createdAt: DateTime.now(),
        );

        final result = await manager.generateSdk(spec, config);
        expect(result.isSuccess, isTrue);
        expect(result.language, equals('dart'));
      });

      test('25. SDK generation error handling', () async {
        final spec = ApiSpecification(
          specId: 'spec_1',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final config = SdkGenerationConfig(
          configId: 'config_1',
          language: 'unsupported',
          packageName: 'test_sdk',
          packageVersion: '1.0.0',
          createdAt: DateTime.now(),
        );

        final result = await manager.generateSdk(spec, config);
        expect(result.isSuccess, isFalse);
        expect(result.error, isNotNull);
      });
    });

    // Documentation Generation Tests (3 tests)
    group('Documentation Generation', () {
      test('26. Markdown documentation config', () {
        final config = DocumentationConfig(
          docConfigId: 'doc_1',
          format: 'markdown',
          title: 'API Documentation',
          includeExamples: true,
          includeErrorCodes: true,
          includeSecurity: true,
          createdAt: DateTime.now(),
        );

        expect(config.format, equals('markdown'));
        expect(config.includeExamples, isTrue);
      });

      test('27. Generate markdown documentation', () async {
        final endpoint = ApiEndpoint(
          endpointId: 'ep_1',
          path: '/api/jobs',
          method: HttpMethod.get,
          summary: 'Get jobs',
          description: 'Retrieve all jobs',
          tags: ['jobs'],
          responses: [
            ApiResponse(
              responseId: 'resp_1',
              statusCode: 200,
              description: 'Success',
              schema: {},
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final spec = ApiSpecification(
          specId: 'spec_1',
          title: 'Job API',
          description: 'API for managing jobs',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [endpoint],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final config = DocumentationConfig(
          docConfigId: 'doc_1',
          format: 'markdown',
          title: 'Job API Documentation',
          createdAt: DateTime.now(),
        );

        final result = await manager.generateDocs(spec, config);
        expect(result.isSuccess, isTrue);
        expect(result.content, contains('Job API'));
        expect(result.endpoints, equals(1));
      });

      test('28. OpenAPI specification export', () async {
        final spec = ApiSpecification(
          specId: 'spec_1',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final yaml = await manager.exportOpenApi(spec);
        expect(yaml, contains('openapi'));
      });
    });

    // Error Code Documentation Tests (2 tests)
    group('Error Code Documentation', () {
      test('29. API error definition', () {
        final error = ApiErrorDefinition(
          errorId: 'err_1',
          statusCode: 404,
          errorCode: 'JOB_NOT_FOUND',
          message: 'Job not found',
          description: 'The requested job does not exist',
          solution: 'Please check the job ID and try again',
          createdAt: DateTime.now(),
        );

        expect(error.statusCode, equals(404));
        expect(error.errorCode, equals('JOB_NOT_FOUND'));
        expect(error.solution, isNotNull);
      });

      test('30. Version management', () {
        final version = ApiVersion(
          versionId: 'v_1',
          version: '1.0.0',
          deprecated: false,
          createdAt: DateTime.now(),
        );

        expect(version.version, equals('1.0.0'));
        expect(version.deprecated, isFalse);
      });
    });

    // Version Compatibility Tests (2 tests)
    group('Version Compatibility', () {
      test('31. Compatibility check - no breaking changes', () async {
        final oldSpec = ApiSpecification(
          specId: 'spec_old',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'Get jobs',
              description: 'Get jobs',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final newSpec = ApiSpecification(
          specId: 'spec_new',
          title: 'API',
          description: 'Description',
          version: '1.1.0',
          baseUrl: 'https://api.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'Get jobs',
              description: 'Get jobs',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            ApiEndpoint(
              endpointId: 'ep_2',
              path: '/jobs/{id}',
              method: HttpMethod.get,
              summary: 'Get job',
              description: 'Get job by id',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await manager.checkCompatibility(oldSpec, newSpec);
        expect(result['isCompatible'], isTrue);
        expect((result['additions'] as List).length, equals(1));
      });

      test('32. Compatibility check - breaking changes', () async {
        final oldSpec = ApiSpecification(
          specId: 'spec_old',
          title: 'API',
          description: 'Description',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'Get jobs',
              description: 'Get jobs',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final newSpec = ApiSpecification(
          specId: 'spec_new',
          title: 'API',
          description: 'Description',
          version: '2.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await manager.checkCompatibility(oldSpec, newSpec);
        expect(result['isCompatible'], isFalse);
        expect((result['breakingChanges'] as List).length, greaterThan(0));
      });
    });

    // Changelog Tests (1 test)
    group('Changelog Generation', () {
      test('33. Changelog generation', () async {
        final entries = [
          ChangelogEntry(
            entryId: 'entry_1',
            version: '1.1.0',
            changeType: 'added',
            description: 'Added new endpoint /jobs/{id}/details',
            releaseDate: DateTime(2026, 3, 15),
          ),
          ChangelogEntry(
            entryId: 'entry_2',
            version: '1.1.0',
            changeType: 'fixed',
            description: 'Fixed rate limiting issue',
            releaseDate: DateTime(2026, 3, 15),
          ),
        ];

        // Note: The service would generate changelog, we just test the data
        expect(entries.length, equals(2));
        expect(entries[0].changeType, equals('added'));
        expect(entries[1].changeType, equals('fixed'));
      });
    });

    // Integration Tests (3 tests)
    group('Integration Tests', () {
      test('34. Full API documentation workflow', () async {
        // Create specification
        final spec = ApiSpecification(
          specId: 'spec_full',
          title: 'Complete API',
          description: 'Full API for testing',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'List jobs',
              description: 'Get all jobs',
              tags: ['jobs'],
              responses: [
                ApiResponse(
                  responseId: 'resp_1',
                  statusCode: 200,
                  description: 'Success',
                  schema: {'type': 'array'},
                  createdAt: DateTime.now(),
                ),
              ],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Generate documentation
        final docConfig = DocumentationConfig(
          docConfigId: 'doc_1',
          format: 'markdown',
          title: 'Complete API Docs',
          createdAt: DateTime.now(),
        );

        final docResult = await manager.generateDocs(spec, docConfig);
        expect(docResult.isSuccess, isTrue);

        // Generate SDK
        final sdkConfig = SdkGenerationConfig(
          configId: 'sdk_1',
          language: 'dart',
          packageName: 'complete_api_client',
          packageVersion: '1.0.0',
          createdAt: DateTime.now(),
        );

        final sdkResult = await manager.generateSdk(spec, sdkConfig);
        expect(sdkResult.isSuccess, isTrue);
      });

      test('35. API versioning workflow', () async {
        final v1 = ApiSpecification(
          specId: 'spec_v1',
          title: 'API v1',
          description: 'Version 1',
          version: '1.0.0',
          baseUrl: 'https://api.v1.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'Get jobs',
              description: 'Get jobs',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final v2 = ApiSpecification(
          specId: 'spec_v2',
          title: 'API v2',
          description: 'Version 2',
          version: '2.0.0',
          baseUrl: 'https://api.v2.example.com',
          endpoints: [
            ApiEndpoint(
              endpointId: 'ep_1',
              path: '/jobs',
              method: HttpMethod.get,
              summary: 'Get jobs',
              description: 'Get jobs',
              deprecated: false,
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            ApiEndpoint(
              endpointId: 'ep_2',
              path: '/jobs/{id}',
              method: HttpMethod.get,
              summary: 'Get job',
              description: 'Get job details',
              responses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final compat = await manager.checkCompatibility(v1, v2);
        expect(compat, isNotNull);
      });

      test('36. Multi-language SDK generation', () async {
        final spec = ApiSpecification(
          specId: 'spec_multi',
          title: 'Multi SDK',
          description: 'For testing',
          version: '1.0.0',
          baseUrl: 'https://api.example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final languages = manager.supportedLanguages();
        expect(languages.length, greaterThan(0));

        for (final lang in languages.take(2)) {
          final config = SdkGenerationConfig(
            configId: 'config_$lang',
            language: lang,
            packageName: 'api_client',
            packageVersion: '1.0.0',
            createdAt: DateTime.now(),
          );

          final result = await manager.generateSdk(spec, config);
          expect(result.language, equals(lang));
        }
      });
    });
  });
}
