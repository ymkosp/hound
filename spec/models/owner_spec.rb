require "spec_helper"

describe Owner do
  describe ".upsert" do
    context "when owner does not exist" do
      it "creates owner" do
        github_id = 1234
        github_name = "thoughtbot"

        Owner.upsert(github_id: github_id, github_name: github_name)

        owner = Owner.find_by(github_id: github_id, github_name: github_name)
        expect(owner).not_to be_nil
      end
    end

    context "when owner exists" do
      it "updates owner github name" do
        owner = create(:owner)
        new_github_name = "ralphbot"

        Owner.upsert(github_id: owner.github_id, github_name: new_github_name)

        expect(owner.reload.github_name).to eq new_github_name
      end
    end
  end
end
