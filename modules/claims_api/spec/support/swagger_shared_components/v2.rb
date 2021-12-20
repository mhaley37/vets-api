# frozen_string_literal: true

module SwaggerSharedComponents
  class V2
    def self.body_examples # rubocop:disable Metrics/MethodLength
      veteran_identifier_json_schema = JSON.parse(
        File.read(
          Rails.root.join(
            'modules',
            'claims_api',
            'config',
            'schemas',
            'v2',
            'request_bodies',
            'veteran_identifier',
            'request.json'
          )
        )
      )

      intent_to_file_json_schema = JSON.parse(
        File.read(
          Rails.root.join(
            'modules',
            'claims_api',
            'config',
            'schemas',
            'v2',
            'request_bodies',
            'intent_to_files',
            'request.json'
          )
        )
      )

      intent_to_file_request_body_example = JSON.parse(
        File.read(
          Rails.root.join(
            'modules',
            'claims_api',
            'config',
            'schemas',
            'v2',
            'request_bodies',
            'intent_to_files',
            'example.json'
          )
        )
      )

      {
        veteran_identifier: {
          in: :body,
          name: 'data',
          required: true,
          description: 'Unique attributes of veteran.',
          schema: {
            type: :object,
            required: veteran_identifier_json_schema['required'],
            properties: veteran_identifier_json_schema['properties']
          }
        },
        intent_to_file: {
          in: :body,
          name: 'data',
          required: true,
          schema: {
            type: :object,
            required: intent_to_file_json_schema['required'],
            properties: intent_to_file_json_schema['properties'],
            example: intent_to_file_request_body_example
          }
        },
        power_of_attorney: {
          in: :body,
          name: 'data',
          required: true,
          schema: {
            type: :object,
            required: ['data'],
            properties: {
              data: {
                type: :object,
                required: ['attributes'],
                example:
                JSON.parse(
                  File.read(
                    Rails.root.join('modules', 'claims_api', 'config', 'post_examples', '2122.json')
                  )
                ),
                properties: {
                  attributes: JSON.parse(
                    File.read(
                      Rails.root.join('modules', 'claims_api', 'config', 'schemas', '2122.json')
                    )
                  )
                }
              }
            }
          }
        }
      }
    end
  end
end