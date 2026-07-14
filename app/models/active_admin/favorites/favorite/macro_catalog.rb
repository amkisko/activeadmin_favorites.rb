# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      class MacroCatalog
        Template = Data.define(:key, :category, :requires_attribute, :resolver)

        CATEGORIES = %i[time_range fiscal].freeze

        def self.all
          @all ||= build_templates.index_by(&:key)
        end

        def self.fetch(key)
          all.fetch(key.to_s) { raise KeyError, "Unknown macro template: #{key}" }
        end

        def self.template_keys
          all.keys
        end

        def self.options_for_select(category: nil)
          templates = all.values
          templates = templates.select { |template| template.category == category.to_sym } if category.present?
          templates.map { |template| [I18n.t("active_admin.favorites.macro_templates.#{template.key}"), template.key] }
        end

        def self.resolve(template_key, attribute:, at: Time.zone.now)
          fetch(template_key).resolver.call(attribute:, at: at.in_time_zone)
        end

        def self.describe(macro)
          case macro["type"]
          when "template"
            attribute = macro["attribute"]
            label = I18n.t("active_admin.favorites.macro_templates.#{macro["name"]}", default: macro["name"].humanize)
            "#{attribute_label(attribute)}: #{label}"
          when "relative_time_range"
            "#{attribute_label(macro["attribute"])}: #{I18n.t("active_admin.favorites.macro_templates.#{macro["preset"]}", default: macro["preset"].humanize)}"
          when "relative_time_bound"
            "#{attribute_label(macro["attribute"])} #{macro["predicate"]} (#{macro["unit"]} #{macro["offset"]})"
          else
            macro["type"].to_s.humanize
          end
        end

        def self.attribute_label(attribute)
          attribute.to_s.tr("_", " ")
        end

        def self.build_templates
          [
            template(:previous_calendar_month, :time_range) { |attribute:, at:|
              month = at.to_date.last_month
              range_bounds(attribute, month.beginning_of_month, month.end_of_month)
            },
            template(:current_calendar_month, :time_range) { |attribute:, at:|
              month = at.to_date
              range_bounds(attribute, month.beginning_of_month, month.end_of_month)
            },
            template(:previous_calendar_day, :time_range) { |attribute:, at:|
              day = at.to_date.yesterday
              range_bounds(attribute, day, day)
            },
            template(:current_calendar_day, :time_range) { |attribute:, at:|
              day = at.to_date
              range_bounds(attribute, day, day)
            },
            template(:rolling_last_7_days, :time_range) { |attribute:, at:|
              day = at.to_date
              range_bounds(attribute, day - 6.days, day)
            },
            template(:rolling_last_30_days, :time_range) { |attribute:, at:|
              day = at.to_date
              range_bounds(attribute, day - 29.days, day)
            },
            template(:previous_fiscal_year, :fiscal) { |attribute:, at:|
              start_date = fiscal_year_start(at.to_date) - 1.year
              range_bounds(attribute, start_date, start_date + 1.year - 1.day)
            },
            template(:current_fiscal_year_to_date, :fiscal) { |attribute:, at:|
              start_date = fiscal_year_start(at.to_date)
              range_bounds(attribute, start_date, at.to_date)
            }
          ]
        end

        def self.template(key, category, &resolver)
          Template.new(
            key: key.to_s,
            category: category,
            requires_attribute: true,
            resolver: resolver
          )
        end

        def self.range_bounds(attribute, from_date, to_date)
          {
            "#{attribute}_gteq" => format_date(from_date),
            "#{attribute}_lteq" => format_date(to_date)
          }
        end

        def self.format_date(value)
          value.to_date.strftime("%Y-%m-%d")
        end

        def self.fiscal_year_start(date)
          year = (date.month >= 4) ? date.year : date.year - 1
          Date.new(year, 4, 1)
        end

        private_class_method :build_templates, :template, :range_bounds, :fiscal_year_start
      end
    end
  end
end
