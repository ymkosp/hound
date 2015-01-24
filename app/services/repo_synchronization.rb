class RepoSynchronization
  ORGANIZATION_TYPE = 'Organization'

  pattr_initialize :user, :github_token
  attr_reader :user

  def start
    user.repos.clear

    api.repos.each do |resource|
      attributes = repo_attributes(resource.to_hash)
      user.repos << Repo.find_or_create_with(attributes)
    end
  end

  private

  def api
    @api ||= GithubApi.new(github_token)
  end

  def repo_attributes(attributes)
    {
      private: attributes[:private],
      github_id: attributes[:id],
      full_github_name: attributes[:full_name],
      in_organization: attributes[:owner][:type] == ORGANIZATION_TYPE,
      owner: upsert_owner(attributes[:owner])
    }
  end

  def upsert_owner(owner_attributes)
    Owner.upsert(
      github_id: owner_attributes[:id],
      github_name: owner_attributes[:login]
    )
  end
end
