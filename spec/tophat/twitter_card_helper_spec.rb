require 'spec_helper'

describe TopHat::TwitterCardHelper do
  before(:all) do
    @title = 'Rain Man'
    @image = 'http://someurl.com/animage.jpg'
    @height = 123
    @width  = 456
  end

  before(:each) do
    @template = ActionView::Base.new
  end

  it 'generates a twitter:card meta tag' do
    @template.twitter_card('summary')

    output = @template.twitter_card
    expect(output).to eq('<meta content="summary" property="twitter:card" />')
  end

  it 'generates twitter:card meta tags' do
    @template.twitter_card('summary') do |card|
      card.url 'http://someurl.com'
      card.title @title
      card.description 'blah blah'
      card.image @image
    end

    output = @template.twitter_card
    expect(output).to include('<meta content="Rain Man" property="twitter:title" />')
    expect(output).to include('<meta content="http://someurl.com/animage.jpg" property="twitter:image" />')
  end

  it 'generates nested twitter:card meta tags' do
    @template.twitter_card('player') do |card|
      card.image @image do |image|
        image.height @height
        image.width @width
      end
    end

    output = @template.twitter_card
    expect(output).to include('<meta content="http://someurl.com/animage.jpg" property="twitter:image" />')
    expect(output).to include('<meta content="123" property="twitter:image:height" />')
    expect(output).to include('<meta content="456" property="twitter:image:width" />')
  end


  it 'generates multiple nested twitter:card meta tags' do
    @template.twitter_card('player') do |card|
      card.player 'https://example.com/embed/a' do |player|
        player.stream 'http://example.com/raw-stream/a.mp4' do |stream|
          stream.content_type '123'
        end
      end
    end

    output = @template.twitter_card
    expect(output).to include('<meta content="http://example.com/raw-stream/a.mp4" property="twitter:player:stream" />')
    expect(output).to include('<meta content="123" property="twitter:player:stream:content_type" />')
  end

  it 'supports default tags' do
    @template.twitter_card('player') do |card|
      card.player do |player|
        player.embed 'https://example.com/embed/a'
      end
    end
    output = @template.twitter_card('player') do |card|
      card.player do |player|
        player.site 'https://example.com'
      end
    end

    expect(output).to include('<meta content="https://example.com/embed/a" property="twitter:player:embed" />')
    expect(output).to include('<meta content="https://example.com" property="twitter:player:site" />')
    expect(output).not_to include('<meta content="https://example.com/embed/a" property="twitter:embed" />')
  end

end
