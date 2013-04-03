#!ruby
# -*- encoding: UTF-8 -*-

require 'aical'

def html(s)
  Nokogiri::HTML::DocumentFragment.parse(s.strip).children.first
end

describe Aical do
  let(:aical) { Aical.new }
  subject { aical }
  before do
    aical.year = 2000; aical.month = 10; aical.day = 10
  end

  describe 'feed_table' do
    let(:table) do
      html(<<-HTML)
        <table cellspacing="0" class="apr">
        <tbody>
        	<tr>
        		<th colspan="3">2013年4月</th>
        	</tr>
        </tbody>
        </table>
      HTML
    end
    before do
      aical.feed_table(table)
    end
    its(:year) { should == 2013 }
    its(:month) { should == 4 }
  end

  describe 'feed_row' do
    let(:tr) do
      html(<<-HTML)
        <tr>
        <td class="schedule-day"><span>03日</span><span class="schedule-week">水</span></td>
        <td><p>x</p></td>
        </tr>
      HTML
    end
    before do
      aical.feed_row(tr)
    end
    its(:day) { should == 3 }
  end

  describe 'parse_item' do
    let(:p) { html('<p class="schedule-game clearfix">いちごちゃん</p>') }
    subject { aical.parse_item(p) }

    it 'content' do
      subject['content'].should == p.text
    end
    it 'date_from' do
      subject['date_from'].should == Time.local(aical.year, aical.month, aical.day)
    end
    it 'date_until' do
      subject['date_until'].should == Time.local(aical.year, aical.month, aical.day)
    end
    it 'type' do
      subject['type'].should == 'game'
    end

    context '中に日付が書かれている(※あり)' do
      let(:p) { html('<p class="schedule-game">あおいちゃん　※2013年2月14日～2014年3月31日</p>') }
      it 'content' do
        subject['content'].should == 'あおいちゃん'
      end
      it 'date_from' do
        subject['date_from'].should == Time.local(2013, 2, 14)
      end
      it 'date_until' do
        subject['date_until'].should == Time.local(2014, 3, 31)
      end
    end

    context '中に日付が書かれている(終了年が無い)' do
      let(:p) { html('<p class="schedule-game">蘭ちゃん　※2013年2月14日～3月31日</p>') }
      it 'content' do
        subject['content'].should == '蘭ちゃん'
      end
      it 'date_from' do
        subject['date_from'].should == Time.local(2013, 2, 14)
      end
      it 'date_until' do
        subject['date_until'].should == Time.local(2013, 3, 31)
      end
    end

    context '中に日付が書かれている(※なし)' do
      let(:p) do
        html(<<-HTML)
          <p class="schedule-game">
          <span>2013年2月14日～2014年3月31日</span>
          おとめちゃん</p>
        HTML
      end
      it 'content' do
        subject['content'].should == 'おとめちゃん'
      end
      it 'date_from' do
        subject['date_from'].should == Time.local(2013, 2, 14)
      end
      it 'date_until' do
        subject['date_until'].should == Time.local(2014, 3, 31)
      end
    end

    context 'リンクがある' do
      let(:p) { html('<p class="schedule-magazine"><a href="../magazine/magazine15.html">ちゃお4月号</a></p>') }
      it 'link' do
        subject['link'].should == 'http://www.aikatsu.com/magazine/magazine15.html'
      end
    end
  end
end
