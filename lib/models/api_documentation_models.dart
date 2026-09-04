/// Phase 35: API Documentation & SDK Generation モデル定義
///
/// API仕様、ドキュメント生成、SDKジェネレーション用モデル

/// HTTPメソッド
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD'),
  options('OPTIONS');

  final String value;
  const HttpMethod(this.value);
}

/// パラメータの位置
enum ParameterLocation {
  path('path'),         // URL パス
  query('query'),       // クエリストリング
  header('header'),     // HTTPヘッダ
  body('body'),         // リクエストボディ
  formData('formData'); // フォームデータ

  final String value;
  const ParameterLocation(this.value);
}

/// パラメータのデータ型
enum DataType {
  string('string'),
  number('number'),
  integer('integer'),
  boolean('boolean'),
  array('array'),
  object('object'),
  file('file');

  final String value;
  const DataType(this.value);
}

/// APIパラメータ定義
class ApiParameter {
  final String parameterId;
  final String name;
  final String description;
  final DataType dataType;
  final ParameterLocation location;
  final bool required;
  final String? defaultValue;
  final String? pattern;          // バリデーションパターン (正規表現)
  final int? minLength;
  final int? maxLength;
  final List<String>? enumValues; // 許可値リスト
  final String? example;
  final DateTime createdAt;

  ApiParameter({
    required this.parameterId,
    required this.name,
    required this.description,
    required this.dataType,
    required this.location,
    this.required = false,
    this.defaultValue,
    this.pattern,
    this.minLength,
    this.maxLength,
    this.enumValues,
    this.example,
    required this.createdAt,
  });
}

/// APIレスポンス定義
class ApiResponse {
  final String responseId;
  final int statusCode;
  final String description;
  final String? contentType;
  final Map<String, dynamic> schema;
  final String? example;
  final Map<String, String>? headers;
  final DateTime createdAt;

  ApiResponse({
    required this.responseId,
    required this.statusCode,
    required this.description,
    this.contentType = 'application/json',
    required this.schema,
    this.example,
    this.headers,
    required this.createdAt,
  });
}

/// APIエンドポイント定義
class ApiEndpoint {
  final String endpointId;
  final String path;
  final HttpMethod method;
  final String summary;
  final String description;
  final String? operationId;
  final List<String> tags;
  final List<ApiParameter> parameters;
  final Map<String, dynamic>? requestBody;
  final List<ApiResponse> responses;
  final bool deprecated;
  final List<String>? securityRequirements;
  final int? rateLimitRequests;
  final int? rateLimitWindowSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiEndpoint({
    required this.endpointId,
    required this.path,
    required this.method,
    required this.summary,
    required this.description,
    this.operationId,
    this.tags = const [],
    this.parameters = const [],
    this.requestBody,
    this.responses = const [],
    this.deprecated = false,
    this.securityRequirements,
    this.rateLimitRequests,
    this.rateLimitWindowSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 完全なエンドポイントパスを返す
  String get fullPath => path;

  /// オペレーション識別子を返す (なければ自動生成)
  String get operationIdOrDefault =>
      operationId ?? '${method.value}_${path.replaceAll('/', '_')}';
}

/// APIリソース定義
class ApiResource {
  final String resourceId;
  final String name;
  final String description;
  final Map<String, dynamic> schema;
  final List<String>? examples;
  final DateTime createdAt;

  ApiResource({
    required this.resourceId,
    required this.name,
    required this.description,
    required this.schema,
    this.examples,
    required this.createdAt,
  });
}

/// API仕様 (OpenAPI互換)
class ApiSpecification {
  final String specId;
  final String title;
  final String description;
  final String version;
  final String baseUrl;
  final List<String>? servers;
  final String? license;
  final String? contactName;
  final String? contactEmail;
  final String? contactUrl;
  final List<ApiEndpoint> endpoints;
  final Map<String, ApiResource> resources;
  final Map<String, dynamic>? securitySchemes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiSpecification({
    required this.specId,
    required this.title,
    required this.description,
    required this.version,
    required this.baseUrl,
    this.servers,
    this.license,
    this.contactName,
    this.contactEmail,
    this.contactUrl,
    this.endpoints = const [],
    this.resources = const {},
    this.securitySchemes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// OpenAPI 3.0形式で仕様をエクスポート
  Map<String, dynamic> toOpenApiSpec() {
    return {
      'openapi': '3.0.0',
      'info': {
        'title': title,
        'description': description,
        'version': version,
        if (contactName != null)
          'contact': {
            'name': contactName,
            if (contactEmail != null) 'email': contactEmail,
            if (contactUrl != null) 'url': contactUrl,
          },
        if (license != null) 'license': {'name': license},
      },
      'servers': [
        {
          'url': baseUrl,
          'description': 'API Server',
        },
        ...?servers?.map((s) => {'url': s}) ?? [],
      ],
      'paths': _buildPathsObject(),
      'components': {
        'schemas': _buildSchemasObject(),
        if (securitySchemes != null) 'securitySchemes': securitySchemes,
      },
    };
  }

  Map<String, dynamic> _buildPathsObject() {
    final paths = <String, dynamic>{};
    for (final endpoint in endpoints) {
      paths.putIfAbsent(endpoint.path, () => {});
      paths[endpoint.path]![endpoint.method.value.toLowerCase()] = {
        'summary': endpoint.summary,
        'description': endpoint.description,
        'operationId': endpoint.operationIdOrDefault,
        'tags': endpoint.tags,
        'parameters': endpoint.parameters
            .map((p) => {
                  'name': p.name,
                  'in': p.location.value,
                  'description': p.description,
                  'required': p.required,
                  'schema': {'type': p.dataType.value},
                })
            .toList(),
        'responses': {
          for (final response in endpoint.responses)
            response.statusCode.toString(): {
              'description': response.description,
              'content': {
                response.contentType ?? 'application/json': {
                  'schema': response.schema,
                }
              }
            }
        }
      };
    }
    return paths;
  }

  Map<String, dynamic> _buildSchemasObject() {
    final schemas = <String, dynamic>{};
    for (final resource in resources.values) {
      schemas[resource.name] = resource.schema;
    }
    return schemas;
  }
}

/// SDK生成設定
class SdkGenerationConfig {
  final String configId;
  final String language;        // dart, typescript, python, java等
  final String packageName;
  final String packageVersion;
  final String? basePackageName;
  final String? outputDirectory;
  final List<String>? includeEndpoints;
  final bool generateModels;
  final bool generateClient;
  final bool generateTests;
  final bool generateDocs;
  final DateTime createdAt;

  SdkGenerationConfig({
    required this.configId,
    required this.language,
    required this.packageName,
    required this.packageVersion,
    this.basePackageName,
    this.outputDirectory,
    this.includeEndpoints,
    this.generateModels = true,
    this.generateClient = true,
    this.generateTests = false,
    this.generateDocs = true,
    required this.createdAt,
  });
}

/// SDK生成結果
class SdkGenerationResult {
  final String resultId;
  final String language;
  final String packageName;
  final int totalFiles;
  final int totalLines;
  final List<String> generatedFiles;
  final DateTime generatedAt;
  final String? error;
  final Duration generationTime;

  SdkGenerationResult({
    required this.resultId,
    required this.language,
    required this.packageName,
    required this.totalFiles,
    required this.totalLines,
    required this.generatedFiles,
    required this.generatedAt,
    this.error,
    required this.generationTime,
  });

  /// 生成が成功したか
  bool get isSuccess => error == null;
}

/// ドキュメント生成設定
class DocumentationConfig {
  final String docConfigId;
  final String format;          // markdown, html, pdf
  final String title;
  final String? logo;
  final bool includeExamples;
  final bool includeErrorCodes;
  final bool includeSecurity;
  final String? theme;
  final DateTime createdAt;

  DocumentationConfig({
    required this.docConfigId,
    required this.format,
    required this.title,
    this.logo,
    this.includeExamples = true,
    this.includeErrorCodes = true,
    this.includeSecurity = true,
    this.theme,
    required this.createdAt,
  });
}

/// ドキュメント生成結果
class DocumentationResult {
  final String resultId;
  final String format;
  final String title;
  final int sections;
  final int endpoints;
  final String content;
  final DateTime generatedAt;
  final String? error;

  DocumentationResult({
    required this.resultId,
    required this.format,
    required this.title,
    required this.sections,
    required this.endpoints,
    required this.content,
    required this.generatedAt,
    this.error,
  });

  /// 生成が成功したか
  bool get isSuccess => error == null;
}

/// APIエラー定義
class ApiErrorDefinition {
  final String errorId;
  final int statusCode;
  final String errorCode;
  final String message;
  final String description;
  final String? solution;
  final DateTime createdAt;

  ApiErrorDefinition({
    required this.errorId,
    required this.statusCode,
    required this.errorCode,
    required this.message,
    required this.description,
    this.solution,
    required this.createdAt,
  });
}

/// APIバージョン管理
class ApiVersion {
  final String versionId;
  final String version;
  final String? releaseNotes;
  final bool deprecated;
  final DateTime? deprecationDate;
  final DateTime? sunsetDate;
  final List<String>? migrateToVersions;
  final DateTime createdAt;

  ApiVersion({
    required this.versionId,
    required this.version,
    this.releaseNotes,
    this.deprecated = false,
    this.deprecationDate,
    this.sunsetDate,
    this.migrateToVersions,
    required this.createdAt,
  });
}

/// チェンジログエントリ
class ChangelogEntry {
  final String entryId;
  final String version;
  final String changeType;     // added, changed, deprecated, removed, fixed, security
  final String description;
  final DateTime releaseDate;

  ChangelogEntry({
    required this.entryId,
    required this.version,
    required this.changeType,
    required this.description,
    required this.releaseDate,
  });
}
