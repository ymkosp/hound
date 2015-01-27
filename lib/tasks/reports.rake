require 'csv'

namespace :reports do
  desc "Run all reports"
  task all: [:north_star, :users, :builds, :subscriptions, :cancellations]

  desc "Prints out number of repos with builds per week."
  task north_star: :environment do
    Report.north_star
  end

  desc 'Prints out new user counts by week.'
  task users: :environment do
    Report.users
  end

  desc 'Prints out build counts by week.'
  task builds: :environment do
    Report.builds
  end

  desc 'Prints out new subscription count by week.'
  task subscriptions: :environment do
    Report.subscriptions
  end

  desc 'Prints out new cancellation count by week.'
  task cancellations: :environment do
    Report.cancellations
  end

  task csv: :environment do
    weeks = Report.weeks
    report = Hash.new { |hash, key| hash[key] = [] }
    new_user_counts = []
    new_subscription_counts = []

    weeks.each do |week|
      weekly_activity_sql = <<-SQL
        SELECT COUNT(distinct repos.id)
        FROM repos
        JOIN builds ON builds.repo_id = repos.id
        WHERE builds.created_at >= '#{week}'
        AND builds.created_at < '#{week + 7.days}'
      SQL

      report[week.to_s] << Repo.connection.execute(weekly_activity_sql).first["count"]

      new_users_by_week_sql = <<-SQL
        SELECT COUNT(*)
        FROM users
        WHERE created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL

      new_user_count = Repo.connection.execute(new_users_by_week_sql).first["count"]
      new_user_counts << new_user_count.to_i
      report[week.to_s] << new_user_count
      report[week.to_s] << new_user_counts.sum

      builds_by_week_sql = <<-SQL
        SELECT COUNT(*)
        FROM builds
        WHERE created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL

      report[week.to_s] << Repo.connection.execute(builds_by_week_sql).first["count"]

      subscriptions_by_week_sql = <<-SQL
        SELECT COUNT(*)
        FROM subscriptions
        WHERE deleted_at IS NULL
        AND created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL

      new_subscription_count = Repo.connection.execute(subscriptions_by_week_sql).first["count"]
      new_subscription_counts << new_subscription_count.to_i
      report[week.to_s] << new_subscription_count
      report[week.to_s] << new_subscription_counts.sum

      cancellations_by_week_sql = <<-SQL
        SELECT COUNT(*)
        FROM subscriptions
        WHERE deleted_at IS NOT NULL
        AND created_at >= '#{week}'
        AND created_at < '#{week + 7.days}'
      SQL

      report[week.to_s] << Repo.connection.execute(cancellations_by_week_sql).first["count"]
    end

    CSV.open("/Users/scott/Dropbox/Documents/hound.report.csv", "wb") do |csv|
      csv << ["week", "north_star", "new_users", "total_users", "builds", "new_subscriptions", "total_subscriptions", "cancellations", "churn"]

      weeks.each do |week|
        csv << [
          week.to_s,
          report[week.to_s][0],
          report[week.to_s][1],
          report[week.to_s][2],
          report[week.to_s][3],
          report[week.to_s][4],
          report[week.to_s][5],
          report[week.to_s][6],
          100 * (report[week.to_s][6].to_f / report[week.to_s][5].to_i)
        ]
      end
    end

    puts "Done!"
  end
end
