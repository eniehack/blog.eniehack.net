# SPDX-License-Identifier: MPL-2.0
require "./lib/git.rb"

include Nanoc::Helpers::Blogging
include Nanoc::Helpers::HTMLEscape
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Breadcrumbs
include Nanoc::Helpers::Tagging
include Nanoc::Helpers::XMLSitemap
include BlogEniehackNet::Helpers::Git

def tag_set(items = nil)
  require "set"
  items = @items if items.nil?
  tags = Set.new
  items.each do |item|
    next if item[:tags].nil?
    item[:tags].each do |tag|
      tags << tag
    end
  end
  return tags.to_a
end

def create_tag_pages
  tag_set(items).each do |tag|
    @items.create(
      "= render('/tags.html.slim', :tag => '#{tag}')",
      { title: "Tags: #{tag}", tag: tag, is_hidden: true },
      "/tags/#{tag}",
    )
  end
end

def set_articles_date
  @items.each do |item|
    next unless item[:kind] == "article"
    dates_hash = find_file_updated ".", "content#{item.identifier.to_s}"
    next if dates_hash[:created_at].nil?

    item[:updated_at] = dates_hash[:updated_at]

    dur = item[:created_at] <=> dates_hash[:created_at]
    next if dur == -1
    item[:created_at] = dates_hash[:created_at]
  end
end
