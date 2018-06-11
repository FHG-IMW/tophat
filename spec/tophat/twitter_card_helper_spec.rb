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

  it 'does not generate a invalid empty twitter:card meta tag' do
    @template.twitter_card()

    output = @template.twitter_card
    expect(output).to eq('')
  end

  it 'generates a twitter:card meta tag' do
    @template.twitter_card('summary')

    output = @template.twitter_card
    expect(output).to eq('<meta content="summary" name="twitter:card" />')
  end

  it 'generates twitter:card meta tags' do
    @template.twitter_card('summary') do |card|
      card.url 'http://someurl.com'
      card.title @title
      card.description 'blah blah'
      card.image @image
    end

    output = @template.twitter_card
    expect(output).to include('<meta content="Rain Man" name="twitter:title" />')
    expect(output).to include('<meta content="http://someurl.com/animage.jpg" name="twitter:image" />')
  end

  it 'generates nested twitter:card meta tags' do
    @template.twitter_card('player') do |card|
      card.image @image do |image|
        image.height @height
        image.width @width
      end
    end

    output = @template.twitter_card
    expect(output).to include('<meta content="http://someurl.com/animage.jpg" name="twitter:image" />')
    expect(output).to include('<meta content="123" name="twitter:image:height" />')
    expect(output).to include('<meta content="456" name="twitter:image:width" />')
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
    expect(output).to include('<meta content="http://example.com/raw-stream/a.mp4" name="twitter:player:stream" />')
    expect(output).to include('<meta content="123" name="twitter:player:stream:content_type" />')
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

    expect(output).to include('<meta content="https://example.com/embed/a" name="twitter:player:embed" />')
    expect(output).to include('<meta content="https://example.com" name="twitter:player:site" />')
    expect(output).not_to include('<meta content="https://example.com/embed/a" name="twitter:embed" />')
  end

end
