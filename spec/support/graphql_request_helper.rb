# frozen_string_literal: true

module GraphqlRequestHelper
  def gql!(query, variables: nil)
    body = {query: query}
    body[:variables] = variables if variables
    post "/admin/graphql", params: body, as: :json
    JSON.parse(response.body)
  end
end
