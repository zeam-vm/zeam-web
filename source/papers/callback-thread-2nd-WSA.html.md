---
title: "Elixirの軽量コールバックスレッドとPhoenixの同時セッション最大数・レイテンシ改善の構想"
---
# Elixirの軽量コールバックスレッドの実装とPhoenixの同時セッション最大数・レイテンシ改善の構想
## 北九州市立大学 山崎 進

# Plan to Implementation of Lightweight Callback Thread for Elixir and Improvement of Maximum Concurrent Sessions and Latency of Phoenix
## Susumu Yamazaki (University of Kitakyushu)

Node.js では，コールバックを用いてI/Oを非同期的に扱って擬似的にマルチタスクにする機構が備わっている[1]。我々はC++で同様の機構を実装し，Zackernelとして公開した[2]。このような仕組みにより，ウェブサーバーがリクエストを受け付ける際に消費するメモリ量を大幅に削減でき，その結果，同時セッション最大数とレイテンシが改善される。そこで，我々はElixirにこのような仕組み，**軽量コールバックスレッド(lightweight callback thread)**を実装することを着想した。これによりElixirベースのウェブサーバープラットフォームであるPhoenixの同時セッション最大数とレイテンシが改善されることを期待している。

本発表では，先行して開発したZackernel(ザッカーネル)の実装について紹介し，Elixirで軽量コールバックスレッドを実装する方針を提案する。次に軽量コールバックスレッドを，従来のマルチタスクの機構であるスケジューラスレッドと非同期スレッドプールとどのように統合していくか，メモリ管理機構との関係をどのように位置づけるかについての方針を提案する。さらにPhoenixで軽量コールバックスレッドをどのように活用するかの方針についても提案する。

今後，我々はElixirに軽量コールバックスレッドのプロトタイプを実装し，性能を評価して前述の提案の実現可能性について検討する。

## 参考文献

* [1]  Stefan Tilkov and Steve Vinoski, Node.js: Using JavaScript to Build High-Performance Network Programs, IEEE Internet Computing, Volume: 14, Issue: 6, Nov.-Dec. 2010.
* [2] Susumu Yamazaki, Zackernel: an Engine for IoT, Sep. 2016. available at https://github.com/zackernel/zackernel
