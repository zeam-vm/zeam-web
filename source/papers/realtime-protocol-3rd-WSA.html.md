---
title: "HTTPでリアルタイム性を保証するために解決すべき技術的課題"
---
# HTTPでリアルタイム性を保証するために解決すべき技術的課題
## 北九州市立大学 大迫 貴，山崎 進，中武 繁寿，藤本 悠介，永原 正章

## 1. はじめに

HTTP/TCP/IPによるプロトコルスタックでのネットワーク通信はベストエフォート方針で設計されている。ベストエフォートが前提だと所定時間内にパケットが確実に到達することを保証できない。一方，機器制御等の組込みシステム目的ではリアルタイム性を要求される。このことから，リモートでネットワーク越しに機器制御を行うような場合，ネットワーク通信のリアルタイム性を保証できない以上，実現が困難であることになる。

本発表の目的は，リモートでネットワーク越しに機器制御を行うケースで，ある程度HTTP通信でもリアルタイム性を担保したいと考えたときに，どのような技術的課題が存在するかをサーベイすることである。本発表を叩き台として議論したい。

本発表のこの後の構成は次のとおりである: 

## 2. 各プロトコルスタックにおけるリアルタイム性を阻害する要因

OSI参照モデルとHTTP/TCP/IPを中心とした各プロトコルの対応関係を図1\[1\]に示す。

| レベル   | 層             | プロトコル | 概要 | 
|--------:|:--------------|:---------|:-----|
| 5, 6, 7 | アプリケーション層| TELNET, SSH, HTTP, SMTP, POP, SSL/TLS, FTP, MIME, HTML, SNMP, MIB, SIP, RTPなど | アプリケーション特有の通信処理を行う |
| 4       | トランスポート層 | TDP, UDP, UDP-Lite, SCTP, DCCPなど | 宛先のアプリケーションにデータを確実に届ける |
| 3       | ネットワーク層   | ARP, IP(v4/v6), ICMP, IPsecなど| 宛先までデータを届ける |
| 2       | データリンク層   |  イーサネット, 無線LAN, PPPなど | 物理層で直接接続されたノード間での通信を可能にする |
| 1       | 物理層          | ツイストペアケーブル, 無線, 光ファイバーなど | 信号と物理的尺度を相互変換する |

図1 OSI参照モデルと各プロトコルの対応関係

以下，各プロトコルスタックについて，リアルタイム性を損ねる要因を列挙するが，これら以外にもOSやミドルウェアのリアルタイム性の不足・欠如によってもリアルタイム性を損ねてしまう。

### 2.1 物理層

物理層におけるリアルタイム性を損ねる要因は，次の通りだと認識している。

* 信号の減衰・衝突・反射
* 障害物の非透過性
* ノイズ
* 無線妨害


### 2.2 データリンク層

データリンク層におけるリアルタイム性を損ねる要因は，次の通りだと認識している。

* フレームの消失・衝突
* フレーム飽和攻撃による通信妨害

### 2.3 ネットワーク層

ネットワーク層におけるリアルタイム性を損ねる要因は，次の通りだと認識している。

* パケットの消失・衝突
* 伝送経路の不定性による伝送時間の変動
* 通信量の変動による伝送時間の変動
* 通信経路のフォールトトレランス性の欠如
* 誤った経路情報による混乱

### 2.4 トランスポート層

トランスポート層におけるリアルタイム性を損ねる要因は，次の通りだと認識している。

* コネクションの確立・維持にかかるコスト
* セグメントの輻輳によるパケット破棄
* ネットワーク層以下のパケット到着順不定性によって起こるパケット順を揃えるための待ち時間
* DDoS攻撃による妨害

### 2.5 アプリケーション層

アプリケーション層におけるリアルタイム性を損ねる要因は，次の通りだと認識している。

* セッションの確立・維持にかかるコスト
* 同期処理による遅延
* DDOS攻撃攻撃

## 3. パケット・ロス

これらの要因の多くはパケット・ロス(packet loss)に起因すると考えた。Bhadra ら\[2\]によるとパケット・ロスの主な原因は次のとおりである。

* 自然に起こる受信障害もしくは人為的な妨害(natural or human-made interference)
	* パケット・ドロップ(packet dropping): ルーターがパケットを受け取ったにも関わらず，ルーターが過負荷である，もしくはルーターが DoS 攻撃を受けていると認識したなどの理由で，次のホップ先にパケットを送らないと決めた場合に起こる
		* ネットワーク輻輳(network congestion)
* システムノイズ(system noise)
* ハードウェア障害(hardware fault)
* ソフトウェア欠陥・障害によるデータ破損(software corruption)

Bhadra ら\[2\]はサーベイの結果，パケット・ロス確率(PLP)に影響を与えるパラメータの効果を次のようにまとめた。

1. 遅延(delay): 遅延が増加するとPLPは減少する。ただし，PLPは遅延したパケットの到着とは独立であるものとする。5,6
2. ルーター負荷(router load): ルーター負荷が増加するとPLPは増加する。7
3. パケット長(packet length): サブスクライバ(subscriber)???が増加するとPLPが増加するのに対し，パケット長が増加するとPLPは減少する。8
4. Hurst パラメータ(Hurst parameter)???: Hurst パラメータが増加するとPLPが増加する。フラクタル開始時間(Fractal onset time)???はPLPを減少させる。タイムスケール(time scale)???はPLPを減少させる。9
5. バッファ・サイズ(buffer size): バッファサイズの増加によってPLPは減少する。10
6. スループット(throughput): スループットによってPLPは増加する。11,12
7. リファレンス・レシーバ(reference receiver)???: リファレンス・レシーバが中央にあるとPLPが増加し，隅にあるとPLPは減少する。13
8. マージン(margin): PLPの値はマージンの値に依存する。マージンが増加したときにPLPはわずかに変化する。14
9. トラフィック負荷(traffic load): トラフィック負荷が増加するとPLPは増加する。15
10. 冗長性(redundancy): 冗長性を加えることでメッセージのパケット・ロスが減少する。18
11. 遅延ジッタ(delay jitter): 同時に他のノードが通信していないときにパケットが通信されて成功するときにPLPは減少する。19
12. 電波領域(radio range): 20
13. チャネル・パケット・ドロップ率(channel packet drop rate): チャネル・パケット・ドロップ率が増加するとPLPは増加する。21
14. フィールド・サイズ(field size): フィールド・サイズが増加するとPLPは減少する。22
15. 閾値(threshold): 出力波長の欠如によってPLPは増加する??? 19,23
16. 出力限界(power limit): 受信出力限界が増加するとPLPは減少する。24
17. 波長(wave length): 波長変換器の回数が増加するとPLPは減少する??? 25
18. 親ピアの数(number of parent peers)???: 親ピアが子ピアを適切に選択することによってPLPは減少する。26

また，Bhadra ら\[2\]が調べた論文それぞれが論じているPLPに影響を与えるパラメータとその効果は表1のとおりである。

表1: PLPに影響を与えるパラメータとその効果についての論文

|番号|参照番号|文献名|発行年|著者|ネットワークの種別|パラメータ|PLPへの影響|
|--:|------:|:----|----:|:--|:-------------|:-------|:---------|
|1|5|Packet loss probability for real time communication|2002|Kelvin et al.|無線|QoS, パケット到着間隔時刻(packet inter arrival time), パケット・ロス比(fraction of packet loss), パケット遅延(packet delay)|パケット遅延が増加するとPLPは減少する, PLPは遅延したパケットの到達とは独立している|
|2|6|Analysis of time delay of packet on multi-service system in loop LAN|2009|Cai Qun et al.|LAN|パケット平均到達レート(the mean arriving rate of the packets), 平均提供時間(the mean serving time), 平均時間遅延(the mean time delay)|時間遅延はパケット・ロスを増加させる|
|3|7|Relationship between packet loss probability and burst parameters for two types of traffic|2012|S. Matsuoka et al.|無線|有音期間(talk spurt), 無音期間(silence period), packet arrival interal, キュー容量(queue capacity), 平均パケットサイズ(average packet size), リンクのバンド幅(bandwidth of the link)|ルーターの負荷が増加するとPLPは増加する|
|4|8|Packet loss probability estimation with a Kalman filter approach|2006|Dongli Zhang and Dan Ionescu|MPLS VPN|バッファサイズ, パケットサイズ, バンド幅, ピークレート(peak rate)|バッファサイズが増加するとPLPは減少する|
|5|9|Loss behavior of an Internet router with self-similar input trafiic via Fractal point process|2013|Rajaiah Dasari and Malla Reddy perati|無線|Hurst parameter, Fractal onset time, time scale|Hurst パラメータが増加するとPLPは増加する。フラクタル開始時間(Fractal onset time)???はPLPを減少させる。タイムスケール(time scale)???はPLPを減少させる|
|6|10|Online packet loss measurement and estimation for VPN based services|2010|Dongli Zhang adn Dang lonescu|VPN|Packet loss, bandwidth|バッファサイズが増加するとPLPが減少する|
|7|11|Fuild flow model for SCTP traffic over the Internet|2012|Perr Azmatshah and Amir Qayyum|無線|到達レート(arrival rate), 生産性(productivity), depature rate, キュー長, 時間スループット(time throuput)| スループットによってPLPは増加する|
|8|12|A system of systems approach: a benchmark to WSNs mobility models|2010|Sh. Al-Shukri et al.|WSN|PLP, スループット, ノードの最適バッファサイズ(optimal buffuer size of nodes), エンドツーエンドの遅延 (end-to-end delay), link and path availability|スループットが増加するにつれてPLPは減少する|
|9|13|Evaluation of PLP in Bluetooth networks|2002|Franco Mazzenga and Dajana Cassioli| MANET| reference receiver, receive power, interference power, thermal noise power|リファレンス・レシーバが中央にあるとPLPが増加し，隅にあるとPLPは減少する。|
|10|14|PLP for bursty wireless real time traffic through delay model|2004|Kelvin K. Lee and Samuel T. Chason|無線|バンド幅, マージン|LPの値はマージンの値に依存する。マージンが増加したときにPLPはわずかに変化する。|

## まとめと将来課題

## 謝辞

本研究の一部は，JST未来社会創造事業 JPMJMI17B4 の支援を受けた。

研究遂行にあたり多くの助言をいただいた北九州工業高等専門学校の滝本 隆先生，北九州市立大学の古閑 宏幸先生，佐藤 敬先生に感謝する。

## 参考文献

* \[1\] マスタリングTCP/IP 入門編 第5版　- 竹下隆史・松山公保・荒井透・苅田幸雄, 1994年 株式会社オーム社, URL:[https://www.ohmsha.co.jp/book/9784274068768/](https://www.ohmsha.co.jp/book/9784274068768/)
* \[2\] D. R. Bhadra, C. A. Joshi, P. R. Soni, N. P. Vyas and R. H. Jhaveri, "Packet loss probability in wireless networks: A survey," 2015 International Conference on Communications and Signal Processing (ICCSP), Melmaruvathur, 2015, pp. 1348-1354, doi: 10.1109/ICCSP.2015.7322729, URL: [http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7322729&isnumber=7322423](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7322729&isnumber=7322423)
