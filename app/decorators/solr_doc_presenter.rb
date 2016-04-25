require 'delegate'


TRIM_LENGTH = 297


class SolrDocPresenter < SimpleDelegator

  def tickets
    @rt_tickets ||= []
  end


  def date_type
    dt = ""
    if !self.date_published.empty?
      dt = "published"
    elsif self.date_published.empty? && !self.date_accepted.empty?
      dt = "accepted"
    end
    dt
  end

  def trim_title
    self.title ? trim_text(self.title, TRIM_LENGTH) : ""
  end

  def trim_abstract
    self.abstract ? trim_text(self.abstract, TRIM_LENGTH) : ""
  end

  def date
    if (self.date_published && !self.date_published.empty?)
      self.date_published
    elsif (self.date_accepted && !self.date_accepted.empty?)
      self.date_accepted
    else
      ""
    end
  end

  # Returns ref to the object we're decorating
  def decoratee
    __getobj__
  end


  private

  # if the text exceeds the limit it will slice the text to the limit and append some continuation characters (...). If the text is less than the limit it is returned unchanged. Used to display text fields in the view
  #
  # @param txt [String] the text to trim
  # @param limit [FixNum] the limit to trim to
  # @return [String] the trimmed or untrimmed text
  def trim_text(txt, limit)
    txt = (txt.size > limit) ?
      (txt.slice(0, limit ) + "...") :
      txt
  end

end #class
