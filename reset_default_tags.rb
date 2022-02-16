Project.includes(:tags).all.each do |project|
    tags = project.tags
  
    tags.each do |tag|
      match_data = tag.name.match(/!.{6}_(critical|high|medium|low|info)/)
  
  
      if match_data
        original_tag_name = match_data.captures[0]
        default_tag = Tag::DEFAULT_TAGS.find { |x| x.split('_')[1] == original_tag_name }
  
        project.issues.includes(:taggings).where(taggings: { tag: tag }).each do |issue|
          issue.tag_list = default_tag
        end
      end
    end
  end
  
  tags = Tag.all
  tags.each do |tag|
    match_data = tag.name.match(/!.{6}_(critical|high|medium|low|info)/)
  
    if match_data
      if !Tag::DEFAULT_TAGS.include?(tag.name)
        tag.destroy
      end
    end
  end