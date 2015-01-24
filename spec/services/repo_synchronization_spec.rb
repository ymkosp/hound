require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'saves privacy flag' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: true,
        owner: {
          type: 'User',
          id: 1,
          login: 'thoughtbot'
        }
      }
      stub_github_api_repos(attributes)
      user = create(:user)
      synchronization = RepoSynchronization.new(user, 'githubtoken')

      synchronization.start

      expect(user.repos.first).to be_private
    end

    it 'saves organization flag' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: false,
        owner: {
          type: 'Organization',
          id: 1,
          login: 'thoughtbot'
        }
      }
      stub_github_api_repos(attributes)
      user = create(:user)
      synchronization = RepoSynchronization.new(user, 'githubtoken')

      synchronization.start

      expect(user.repos.first).to be_in_organization
    end

    it 'replaces existing repos' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: false,
        owner: {
          type: 'User',
          id: 1,
          login: 'thoughtbot'
        }
      }
      stub_github_api_repos(attributes)
      membership = create(:membership)
      user = membership.user
      synchronization = RepoSynchronization.new(user, 'githubtoken')

      synchronization.start

      expect(user.repos.size).to eq(1)
      expect(user.repos.first.full_github_name).to eq 'user/newrepo'
      expect(user.repos.first.github_id).to eq 456
    end

    it 'renames an existing repo if updated on github' do
      membership = create(:membership)
      repo_name = 'user/newrepo'
      attributes = {
        full_name: repo_name,
        id: membership.repo.github_id,
        private: true,
        owner: {
          type: 'User',
          id: 1,
          login: 'thoughtbot'
        }
      }
      stub_github_api_repos(attributes)
      synchronization = RepoSynchronization.new(membership.user, 'githubtoken')

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq repo_name
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        first_membership = create(:membership)
        repo = first_membership.repo
        attributes = {
          full_name: repo.full_github_name,
          id: repo.github_id,
          private: true,
          owner: {
            type: 'User',
            id: 1,
            login: 'thoughtbot'
          }
        }
        stub_github_api_repos(attributes)
        second_user = create(:user)
        synchronization = RepoSynchronization.new(second_user, 'githubtoken')

        synchronization.start

        expect(second_user.reload.repos.size).to eq(1)
      end
    end

    describe "repo owners" do
      context "when the owner doesn't exit" do
        it "creates and associates an owner to the repo" do
          user = create(:user)
          owner_github_id = 1234
          owner_name = 'thoughtbot'
          repo_github_id = 321
          attributes = {
            full_name: 'thoughtbot/newrepo',
            id: repo_github_id,
            private: true,
            owner: {
              type: 'Organization',
              id: owner_github_id,
              login: owner_name
            }
          }
          stub_github_api_repos(attributes)
          synchronization = RepoSynchronization.new(user, 'githubtoken')

          synchronization.start

          owner = Owner.find_by(github_id: owner_github_id)
          expect(owner.github_name).to eq(owner_name)
          expect(owner.repos.map(&:github_id)).to include(repo_github_id)
        end
      end

      context "when the owner exists" do
        it "updates and associates an owner to the repo" do
          owner = create(:owner)
          user = create(:user)
          repo_github_id = 321
          attributes = {
            full_name: 'thoughtbot/newrepo',
            id: repo_github_id,
            private: true,
            owner: {
              type: 'Organization',
              id: owner.github_id,
              login: owner.github_name
            }
          }
          stub_github_api_repos(attributes)
          synchronization = RepoSynchronization.new(user, 'githubtoken')

          synchronization.start

          owner = Owner.find_by(github_id: owner.github_id)
          expect(owner.repos.map(&:github_id)).to include(repo_github_id)
        end
      end
    end

    def stub_github_api_repos(attributes)
      resource = double(:resource, to_hash: attributes)
      api = double(:github_api, repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
    end
  end
end
