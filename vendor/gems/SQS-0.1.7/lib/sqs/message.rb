#!/usr/local/bin/ruby

class SQS::Message
  attr_accessor :queue, :_body, :id

  def initialize( options={} )
    self.body = options.is_a?( Hash ) ? options[:body] : nil
    self.queue = options.is_a?( Hash ) ? options[:queue] : nil
    self.id = options.is_a?( Hash ) ? options[:id] : options.to_s
  end


  def delete
    raise SQS::UnavailableQueue, "This #{self.class.to_s} cannot be deleted, because there is no associated SQS::Queue" unless self.queue.is_a?( SQS::Queue )
    raise SQS::MissingId, "Cannot delete a message with no id." if self.id.to_s.empty?

    doc = SQS.call_web_service( :Action => 'DeleteMessage', :queue => self.queue, :MessageId => self.id )
    true
  rescue Exception => e
    raise e
  end


  def peek
    raise SQS::UnavailableQueue, "This #{self.class.to_s} cannot be peeked, because there is no associated SQS::Queue" unless self.queue.is_a?( SQS::Queue )
    raise SQS::MissingId, "Cannot peek a message with no id." if self.id.to_s.empty?

    doc = SQS.call_web_service( :Action => 'PeekMessage', :queue => self.queue, :MessageId => self.id )
    self.body = doc.message_body
    true
  rescue Exception => e
    raise e
  end

  def body 
    self.peek if self._body.to_s.empty?
    self._body
  end
  def body=( b )
    self._body = b
  end

end

class SQS::UnavailableQueue < TypeError ; end
class SQS::MissingId < TypeError ; end
