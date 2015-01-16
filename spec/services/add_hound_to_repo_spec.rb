require "fast_spec_helper"
require "app/services/add_hound_to_repo"
require "app/models/github_user"

describe AddHoundToRepo do
  describe "#run" do
    context "with org repo" do
      context "when Services team does not exist" do
        context "when repo is part of a team" do
          it "adds hound to new Services team" do
            github = build_github

            services_team_id = 1001
            services_team = double("GithubTeam", id: services_team_id)
            allow(github).to receive(:create_team).and_return(services_team)

            allow(github).to receive(:add_user_to_team).and_return(true)

            AddHoundToRepo.run(github.repo.name, github)

            expect(github).to have_received(:create_team).with(
              org_name: github.repo.organization.login,
              team_name: AddHoundToRepo::SERVICES_TEAM_NAME,
              repo_name: github.repo.name
            )
            expect(github).to have_received(:add_user_to_team).
              with(hound, services_team_id)
          end
        end

        context "when repo is not part of a team" do
          it "adds hound to new Services team" do
            github = build_github(user_teams: [], repo_teams: [])

            services_team_id = 1001
            services_team = double("GithubTeam", id: services_team_id)
            allow(github).to receive(:create_team).and_return(services_team)

            allow(github).to receive(:add_user_to_team)

            AddHoundToRepo.run(github.repo.name, github)

            expect(github).to have_received(:create_team).with(
              org_name: github.repo.organization.login,
              team_name: AddHoundToRepo::SERVICES_TEAM_NAME,
              repo_name: github.repo.name
            )
            expect(github).to have_received(:add_user_to_team).
              with(hound, services_team_id)
          end
        end
      end

      context "when Services team does exist" do
        xcontext "when repo is part of a team" do

        end

        context "when repo is not part of a team" do
          it "adds user to existing Services team" do
            services_team_id = 1001
            services_team = build_team(
              id: services_team_id,
              name: AddHoundToRepo::SERVICES_TEAM_NAME,
              permission: "push"
            )

            github = build_github(user_teams: [], repo_teams: [], org_teams: [services_team])

            allow(github).to receive(:add_user_to_team)
            allow(github).to receive(:add_repo_to_team)

            AddHoundToRepo.run(github.repo.name, github)

            expect(github).to have_received(:add_user_to_team).
              with(hound, services_team_id)
          end
        end
      end

      context "when Services team has pull access" do
        it "updates permissions to push access" do
          github_team =
            double("RepoTeams", id: 222, name: "Services", permission: "pull")
          github = build_github(user_teams: [], org_teams: [github_team])
          allow(github).to receive(:add_user_to_team)
          allow(github).to receive(:update_team)
          allow(github).to receive(:add_repo_to_team)

          AddHoundToRepo.run("foo/bar", github)

          expect(github).to have_received(:update_team).
            with(github_team.id, permission: "push")
        end
      end
    end

    context "when repo is not part of an organization" do
      it "adds user as collaborator" do
        repo_name = "foo/bar"
        github_repo = double("GithubRepo", organization: false)
        github = double("GithubApi", repo: github_repo, add_collaborator: nil)

        AddHoundToRepo.run(repo_name, github)

        expect(github).to have_received(:add_collaborator).
          with(repo_name, hound)
      end
    end
  end

  def build_team(args = { id: 10, permission: "admin" })
    double("GithubTeam", args)
  end

  def build_repo
    double("GithubRepo", name: "foo/bar", organization: double("Organization", login: "foo"))
  end

  def build_github(user_teams: [build_team], repo_teams: [build_team], org_teams:[])
    double(
      "GithubApi",
      repo: build_repo,
      org_teams: org_teams,
      repo_teams: repo_teams,
      user_teams: user_teams
    )
  end

  def hound
    ENV["HOUND_GITHUB_USERNAME"]
  end
end
