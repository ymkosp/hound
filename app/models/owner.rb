class Owner < ActiveRecord::Base
  def self.upsert(github_id:, github_name:)
    owner = find_by(github_id: github_id)

    if owner.nil?
      Owner.create(github_id: github_id, github_name: github_name)
    elsif owner.github_name != github_name
      owner.update(github_name: github_name)
    end
  end
end
