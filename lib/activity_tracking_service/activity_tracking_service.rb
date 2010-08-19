require 'singleton'

class ActivityTrackingService
  include Singleton

  attr_accessor :period, :charges, :counter

  def initialize
    @counter = -1
  end

  def update(*args)
    send(*args)
  end


  #########
  # Hooks #
  #########

  def supported(echoable, user)
    echoable.add_subscriber(user)
  end

  def unsupported(echoable, user)
    echoable.remove_subscriber(user)
  end

  def incorporated(echoable, user)
  end


  #################
  # Service logic #
  #################

  #
  # Manages the counter to calculate current charge and schedules the next job with it.
  #
  def enqueue_activity_tracking_job(current_charge = 0)

    # After restarting the process (on new deployment) the
    # counter is initialized with the first running charge.
    @counter = current_charge if @counter == -1

    # Enqueuing the next job
    @counter += 1
    Delayed::Job.enqueue ActivityTrackingJob.new(@counter % @charges), 0,
                         Time.now.utc.advance(:seconds => @period/@charges)
  end

  #
  # Actually executes the job, generates activity mails, sends them and schedules the next job.
  #
  def generate_activity_mails(current_charge)

    # Enqueuing the next job
    enqueue_activity_tracking_job(current_charge)

    # Calculating 'after time' to minimize timeframe errors due to long lasting processes
    # FIXME: correct solution should be to persist the last_notification time per user
    after_time = @period.ago.utc - 5.minutes  # with 5 minutes safety buffer (some events might be delivered twice)

    # Iterating over users in the current charge
    User.all(:conditions => ["(id % ?) = ? and activity_notification = 1", @charges, current_charge]).each do |recipient|

      # Collecting events
      events = Event.find_tracked_events(recipient, after_time)
      puts "events: #{events.size}"
      next if events.blank? #if there are no events to send per email, take the next user

      question_events = events.select{|e|JSON.parse(e.event).keys[0] == 'question'}
      tags = Hash.new
      question_events.each do |question|
        question_data = JSON.parse(question.event)
        question_data['question']['tao_tags'].each do |tao_tag|
          tags[tao_tag['tag']['value']] = tags[tao_tag['tag']['value']] ? tags[tao_tag['tag']['value']] + 1 : 1
        end
      end
      events.sort! do |a,b|
        a_parsed = JSON.parse(a.event)
        root_x = a_parsed[a_parsed.keys[0]]['root_id'] || -1
        parent_x = a_parsed[a_parsed.keys[0]]['parent_id'] || -1
        b_parsed = JSON.parse(b.event)
        root_y = b_parsed[b_parsed.keys[0]]['root_id'] || -1
        parent_y = b_parsed[b_parsed.keys[0]]['parent_id'] || -1
        [root_x,parent_x] <=> [root_y,parent_y]
      end

      # Sending the mail
      send_activity_email(recipient, question_events, tags, events - question_events)
    end
  end

  #
  # Sends an activity tracking E-Mail to the given recipient.
  #
  def send_activity_email(recipient, question_events, question_tags, events)
    puts "Send mail to:" + recipient.email
    mail = ActivityTrackingMailer.create_activity_tracking_email(recipient,
                                                                 question_events,
                                                                 question_tags,
                                                                 events)
    ActivityTrackingMailer.deliver(mail)
  end

  #handle_asynchronously :send_activity_email

end