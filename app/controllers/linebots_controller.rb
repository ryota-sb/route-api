class LinebotsController < ApplicationController
  require 'line/bot'
  require 'date'

  protect_from_forgery :except => [:callback]

  # 完了タスクのリセット
  def reset_tasks(week)
    tasks = Task.where(is_done, true, week, week)
    tasks.update.all(is_done: false)
    return '今日のタスクをリセットしました！'
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

  events.each do |event|
    reply_text_list = []
    case event.message['text']
    when 'リセット'
      reply_text_list.push(reset_tasks(get_day_of_the_week))
    else
      reply_text_list.push('そのコマンドはありません')
    end

    case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message_array = reply_text_lists.map do |reply_text|
            { type: 'text', text: reply_text }
          end
          client.reply_message(event['replyToken'], message_array)
        end
      end
    end
    head :ok
  end

  def recieve
    body = request.body.read
    events = client.parse_events_from(body)
    events.each do |event|
      userId = event.source.user_id
      p userId
    end
  end

  private

  # Lineアカウント取得
  def client
    @client ||= Line::Bot::Client.new |config| do
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end

  # 今日の曜日をリスト内の文字列で取得
  def get_day_of_the_week
    data = Date.today
    week_lists = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
    return week_lists[data.wday]
  end
end