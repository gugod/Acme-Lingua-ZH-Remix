package Acme::Lingua::ZH::Remix;
use common::sense;
use List::MoreUtils qw(uniq);

our $VERSION = "0.11";

sub import {
    my $pkg = (caller)[0];
    {
        no strict 'refs';
        *{$pkg . '::rand_sentence'} = \&rand_sentence
            if not defined &{$pkg . '::rand_sentence'};
    }
}

my @phrase_db;
my %phrase;

sub init_phrase {
    my $corpus = shift;

    # Squeeze whitespaces
    $corpus =~ s/(\s|　)*//gs;

    # Ignore certain punctuations
    $corpus =~ s/——//gs;

    my @x = split /(?:（(.+?)）|：?「(.+?)」|〔(.+?)〕|“(.+?)”)/, $corpus;
    @phrase_db =
        uniq sort
        map {
            s/^(，|。|？|\s)+//;
            $_;
        } grep /\S/, map {
            @_ = ();
            # s/(.+?(?:，|。|？)+)//gsm;
            my @x = split /(，|。|？)/;
            while(@x) {
                my $s = shift @x;
                my $p = shift @x;

                push @_, "$s$p";
            }

            @_;
        } grep /\S/, map {
            s/^\s+//;
            s/\s+$//;
            s/^(.+?) //;
            $_;
        } @x;

    %phrase = {};

    for (@phrase_db) {
        # say $_;
        my $p = substr($_, -1);
        push @{$phrase{$p} ||=[]}, $_;
    }
}

sub phrase_ratio {
    my $type = shift;
    return @{$phrase{$type}} / @phrase_db
}

sub rand_phrase {
    my $type = shift;
    $phrase{ $type }[int rand @{$phrase{ $type }}];
}

sub rand_sentence {
    unless (%phrase) {
        local $/ = undef;
        init_phrase(<DATA>);
    }

    my $str = "";

    while($str eq "") {
        for ('」',  '，' ,'，' , '）', '，') {
            $str .= rand_phrase($_) if rand() < phrase_ratio($_);
        }
    }

    my $ending;
    if (rand > 0.5) {
        $ending = rand_phrase("。")
    }
    else {
        $ending = rand_phrase("？");
    }

    unless($ending) {
        $str =~ s/，$//;
        $ending = "..." unless $str =~ /」$/;
        $str =~ s/^「(.+)」$/$1/;
    }

    $str .= $ending;

    if (rand > 0.5) {
        $str =~ s/(，)……/$1/gs;
    } else {
        $str =~ s/，(……)/$1/gs;
    }

    return $str;
}

1;

=head1 NAME

Acme::Lingua::ZH::Remix - The Chinese sentence generator.

=head1 SYNOPSIS

    use Acme::Lingua::ZH::Remix;

    rand_sentence;

=head1 DESCRIPTION

The exported function C<rand_sentence> returns a string of one sentence
of Chinese like:

    真是完全失敗，孩子！怎麼不動了呢？

It uses the corpus data from Project Gutenberg by default. All
generate sentences are remixes of the corpus.

You can feed you own corpus data with `init_phrase` function:

    Acme::Lingua::ZH::Remix::init_phrase($my_corpus);
    say rand_santence; # based on $my_corpus

This will effectively clear the default corpus, and any other corpus
fed into it before. The corpus should use full-width punction
characters.

Warning: The C<rand_sentence> function has non-zero chance entering an
infinte loop.

=head1 COPYRIGHT

Copyright 2010 by Kang-min Liu, <gugod@gugod.org>

This program is free software; you can redistribute it a nd/or modify
it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

# Data coming from Project Gutenberg.
# http://www.gutenberg.org/etext/25242

__DATA__
野草/魯迅

《野草》題辭

當我沈默著的時候，我覺得充實；我將開口，同時感到空虛。

過去的生命已經死亡。我對於這死亡有大歡喜，因為我藉此知道它曾經存活。死亡的生
命已經朽腐。我對於這朽腐有大歡喜，因為我藉此知道它還非空虛。

生命的泥委棄在地面上，不生喬木，只生野草，這是我的罪過。

野草，根本不深，花葉不美，然而吸取露，吸取水，吸取陳死人的血和肉，各各奪取它
的生存。當生存時，還是將遭踐踏，將遭刪刈，直至於死亡而朽腐。

但我坦然，欣然。我將大笑，我將歌唱。

我自愛我的野草，但我憎惡這以野草作裝飾的地面。

地火在地下運行，奔突；熔岩一旦噴出，將燒盡一切野草，以及喬木，於是並且無可朽
腐。

但我坦然，欣然。我將大笑，我將歌唱。

天地有如此靜穆，我不能大笑而且歌唱。天地即不如此靜穆，我或者也將不能。我以這
一叢野草，在明與暗，生與死，過去與未來之際，獻於友與仇，人與獸，愛者與不愛者
之前作證。

為我自己，為友與仇，人與獸，愛者與不愛者，我希望這野草的朽腐，火速到來。要不
然，我先就未曾生存，這實在比死亡與朽腐更其不幸。

去罷，野草，連著我的題辭！

魯迅記於廣州之白雲樓上

秋夜

在我的後園，可以看見晱~有兩株樹，一株是棗樹，還有一株也是棗樹。

這上面的夜的天空，奇怪而高，我生平沒有見過這樣奇怪而高的天空。他彷彿要離開人
間而去，使人們仰面不再看見。然而現在卻非常之藍，閃閃地夾著幾十個星星的眼，冷
眼。他的口角上現出微笑，似乎自以為大有深意，而將繁霜灑在我的園裡的野花草上。

我不知道那些花草真叫什麼名字，人們叫他們什麼名字。我記得有一種開過極細小的粉
紅花，現在還開著，但是更極細小了，她在冷的夜氣中，瑟縮地做夢，夢見春的到來，
夢見秋的到來，夢見瘦的詩人將眼淚擦在她最末的花瓣上，告訴她秋雖然來，冬雖然來
，而此後接著還是春蝴蝶亂飛，蜜蜂都唱起春詞來了。她於是一笑，雖然顏色凍得紅慘
慘地，仍然瑟縮著。

棗樹，他們簡直落盡了葉子。先前，還有一兩個孩子來打他們別人打剩的棗子，現在是
一個也不剩了，連葉子也落盡了。他知道小粉紅花的夢，秋後要有春；他也知道落葉的
夢，春後還是秋。他簡直落盡葉子，單剩幹子，然而脫了當初滿樹是果實和葉子時候的
弧形，欠伸得很舒服。但是，有幾枝還低椏著，護定他從打棗的竿梢所得的皮傷，而最
直最長的幾枝，卻已默默地鐵似的直刺著奇怪而高的天空，使天空閃閃地鬼夾眼；直刺
著天空中圓滿的月亮，使月亮窘得發白。

鬼夾眼的天空越加非常之藍，不安了，彷彿想離去人間，避開棗樹，只將月亮剩下。然
而月亮也暗地躲到東邊去了。而一無所有的幹子，卻仍然默默地鐵似的直刺著奇怪而高
的天空，一意要制他的死命，不管他各式各樣地夾著許多蠱惑的眼睛。

哇的一聲，夜游的惡鳥飛過了。

我忽而聽到夜半的笑聲，吃吃地，似乎不願意驚動睡著的人，然而四圍的空氣都應和著
笑。夜半，沒有別的人，我即刻聽出這聲音就在我嘴裡，我也即劇被這笑聲所驅逐，回
進自己的房。燈火的帶子也即刻被我旋高了。

後窗的玻璃上丁丁地響，還有許多小飛蟲亂撞。不多久，幾個進來了，許是從窗紙的破
孔進來的。他們一進來，又在玻璃的燈罩上撞得丁丁地響。一個從上面撞進去了，他於
是遇到火，而且我以為這火是真的。兩三個卻休息在燈的紙罩上喘氣。那罩是昨晚新換
的罩，雪白的紙，折出波浪紋的疊痕，一角還畫出一枝猩紅色的梔子。

猩紅的梔子開花時，棗樹又要做小粉紅花的夢，青蔥地彎成弧形了……。我又聽到夜半
的笑聲，我趕緊砍斷我的心緒，看那老在白紙罩上的小青蟲，頭大尾小，嚮日葵子似的
，只有半粒小麥那麼大，遍身的顏色蒼翠得可愛，可憐。

我打一個叮欠，點起一支紙煙，噴出煙來，對著燈默默地敬奠這些蒼翠精緻的英雄們。

影的告別

人睡到不知道時候的時候，就會有影來告別，說出那些話──

有我所不樂意的在地獄裡，我不願去；有我所不樂意的在地獄裡，我不願去；有我所不
樂意的在你們將來的黃金世界裡，我不願去。

然而你就是我所不樂意的。

朋友，我不想跟隨你，我不願住。

我不願意！

嗚乎嗚乎，我不願意，我不如彷徨於無地。

我不過一個影，要別你而沉沒在黑暗裡了。然而黑暗又會吞併我，然而光明又會使我消
失。

然而我不願彷徨於明暗之間，我不如在黑暗裡沉沒。

然而我終於彷徨於明暗之間，我不知道是黃昏還是黎明。我姑且舉灰黑的手裝作喝幹一
杯酒，我將在不知道時候的時候獨自遠行。

嗚乎嗚乎，倘若黃昏，黑夜自然會來沉沒我，否則我要被白天消失，如果現是黎明。

朋友，時候近了。

我將向黑暗裡彷徨於無地。

你還想我的贈品。我能獻你甚麼呢？無已，則仍是黑暗和虛空而已。但是，我願意只是
黑暗，或者會消失於你的白天；我願意只是虛，決不占你的心地。

我願意這樣，朋友──

我獨自遠行，不但沒有你，並且再沒有別的影在黑暗裡。只有我被黑暗沉沒，那世界全
屬於我自己。

求乞者

我順著剝落的高晲姜禲A踏著鬆的灰土。另外有幾個人，各自走路。微風起來，露在
頭的高樹的枝條帶著還未幹枯的葉子在我頭上搖動。

微風起來，四面都是灰土。

一個孩子向我求乞，也穿著夾衣，也不見得悲戚，近於兒戲；我煩膩他這追著哀呼。

我走路。另外有幾個人各自走路。微風起來，四面都是灰土。

一個孩子向我求乞，也穿著夾衣，也不見得悲戚，但是啞的，攤開手，裝著手勢。

我就憎惡他這手勢。而且，他或者並不啞，這不過是一種求乞的法子。

我不佈施，我無佈施心，我但居佈施者之上，給與煩膩，疑心，憎惡。

我順著倒敗的泥晲姜禲A斷磚疊在棬吨f，湀堶惆S有什麼。微風起來，送秋寒穿透我
的夾衣；四面都是灰土。

我想著我將用什麼方法求乞：發聲，用怎樣聲調？裝啞，用怎樣手勢？……

另外有幾個人各自走路。

我將得不到佈施，得不到佈施心；我將得到自居於佈施之上者的煩膩，疑心，憎惡。

我將用無所為和沉默求乞！……

我至少將得到虛無。

微風起來，四面都是灰土。另外有幾個人各自走路。

灰土，灰土，……

……

灰土……

我的失戀

——擬古的新打油詩——

我的所愛在山腰；

想去尋她山太高，

低頭無法淚沾袍。

愛人贈我百蝶巾；

回她什麼：貓頭鷹。

從此翻臉不理我，

不知何故兮使我心驚。

我的所愛在鬧市；

想去尋她人擁擠，

仰頭無法淚沾耳。

愛人贈我雙燕圖；

回她什麼：冰糖壺廬。

從此翻臉不理我，

不知何故兮使我胡塗。

我的所愛在河濱；

想去尋她河水深，

歪頭無法淚沾襟。

愛人贈我金錶索；

回她什麼：發汗藥。

從此翻臉不理我，

不知何故兮使我神經衰弱。

我的所愛在豪家；

想去尋她兮沒有汽車，

搖頭無法淚如麻。

愛人贈我玫瑰花；

回她什麼：赤練蛇。

從此翻臉不理我，

不知何故兮——由她去罷。

復仇

人的皮膚之厚，大概不到半分，鮮紅的熱血，就循著那後面，在比密密層層地爬在椈
上的槐蠶更其密的血管堜b流，散出溫熱。於是各以這溫熱互相蠱惑，煽動，牽引，拼
命希求偎倚，接吻，擁抱，以得生命的沉酣的大歡喜。

但倘若用一柄尖銳的利刃，衹一擊，穿透這桃紅色的，菲薄的皮膚，將見那鮮紅的熱血
激箭似的以所有溫熱直接灌溉殺戮者；其次，則給以冰冷的呼吸，示以淡白的嘴唇，使
之人性茫然，得到生命的飛揚的極致的大歡喜；而其自身，則永遠沉浸於生命的飛揚的
極致的大歡喜中。

這樣，所以，有他們倆裸著全身，捏著利刃，對立於廣漠的曠野之上。

他們倆將要擁抱，將要殺戮……

路人們從四面奔來，密密層層地，如槐蠶爬上椈嚏A如馬蟻要扛鯗頭。衣服都漂亮，手
倒空的。然而從四面奔來，而且拼命地伸長脖子，要賞鑒這擁抱或殺戮。他們已經預覺
著事後自己的舌上的汗或血的鮮味。

然而他們倆對立著，在廣漠的曠野之上，裸著全身，捏著利刃，然而也不擁抱，也不殺
戮，而且也不見有擁抱或殺戮之意。

他們倆這樣地至於永久，圓活的身體，已將幹枯，然而毫不見有擁抱或殺戮之意。

路人們於是乎無聊；覺得有無聊鑽進他們的毛孔，覺得有無聊從他們自己的心中由毛孔
鑽出，爬滿曠野，又鑽進別人的毛孔中。他們於是覺得喉舌幹燥，脖子也乏了；終至於
面面相覷，慢慢走散；甚而至於居然覺得幹枯到失了生趣。

於是衹剩下廣漠的曠野，而他們倆在其間裸著全身，捏著利刃，幹枯地立著；以死人似
的眼光，賞鑒這路人們的幹枯，無血的大戮，而永遠沉浸於生命的飛揚的極致的大歡喜
中。

復仇 (其二)

因為他自以為神之子，以色列的王，所以去釘十字架。

兵丁們給他穿上紫袍，戴上荊冠，慶賀他；又拿一根葦子打他的頭，吐他，屈膝拜他；
戲弄完了，就給他脫了紫袍，仍穿他自己的衣服。

看哪，他們打他的頭，吐他，拜他……

他不肯喝那用沒藥調和的酒，要分明地玩味以色列人怎樣對付他們的神之子，而且較永
久地悲憫他們的前途，然而仇恨他們的現在。

四面都是敵意，可悲憫的，可咒詛的。

丁丁地想，釘尖從掌心穿透，他們要釘殺他們的神之子了；可憫的人們呵，使他痛得柔
和。丁丁地想，釘尖從腳背穿透，釘碎了一塊骨，痛楚也透到心髓中，然而他們釘殺著
他們的神之子了，可咒詛的人們呵，這使他痛得舒服。

十字架豎起來了；他懸在虛空中。

他沒有喝那用沒藥調和的酒，要分明地玩味以色列人怎樣對付他們的神之子，而且較永
久地悲憫他們的前途，然而仇恨他們的現在。

路人都辱罵他，祭司長和文士也戲弄他，和他同釘的兩個強盜也譏誚他。

看哪，和他同釘的……

四面都是敵意，可悲憫的，可咒詛的。

他在手足的痛楚中，玩味著可憫的人們的釘殺神之子的悲哀和可咒詛的人們要釘殺神之
子，而神之子就要被釘殺了的歡喜。突然間，碎骨的大痛楚透到心髓了，他即沉酣於大
歡喜和大悲憫中。

他腹部波動了，悲憫和咒詛的痛楚的波。

遍地都黑暗了。

“以羅伊，以羅伊，拉馬撒巴各大尼？！”〔翻出來，就是：我的上帝，你為甚麼離棄
我？！〕

上帝離棄了他，他終於還是一個“人之子”；然而以色列人連“人之子”都釘殺了。

釘殺了“人之子”的人們身上，比釘殺了“神之子”的尤其血污，血腥。

希望

我的心分外地寂寞。

然而我的心很平安；沒有愛憎，沒有哀樂，也沒有顏色和聲音。

我大概老了。我的頭髮已經蒼白，不是很明白的事麼？我的手顫抖著，不是很明白的事
麼？那麼我的靈魂的手一定也顫抖著，頭髮也一定蒼白了。

然而這是許多年前的事了。

這以前，我的心也曾充滿過血腥的歌聲：血和鐵，火焰和毒，恢復和報仇。而忽然這些
都空虛了，但有時故意地填以沒奈何的自欺的希望。希望，希望，用這希望的盾，抗拒
那空虛中的暗夜的襲來，雖然盾後面也依然是空虛中的暗夜。然而就是如此，陸續地耗
盡了我的青春。

我早先豈不知我的青春已經逝去？但以為身外的青春固在：星，月光，僵墜的蝴蝶，暗
中的花，貓頭鷹的不祥之言，杜鵑的啼血，笑的渺茫，愛的翔舞。……雖然是悲涼漂渺
的青春罷，然而究竟是青春。

然而現在何以如此寂寞？難道連身外的青春也都逝去，世上的青年也多衰老了麼？

我衹得由我來肉薄這空虛中的暗夜了。我放下了希望之盾，我聽到Petofi Sandor(1823-49)
的“希望”之歌：

希望是什麼？是娼妓：

她對誰都蠱惑，將一切都獻給；

待你犧牲了極多的寶貝——

你的青春——她就拋棄你。

這偉大的抒情詩人，匈牙利的愛國者，為了祖國而死在可薩克兵的矛尖上，已經七十五
年了。悲哉死也，然而更可悲的是他的詩至今沒有死。

但是，可慘的人生！桀驁英勇如Petofi，也終於對了暗夜止步，回顧茫茫的東方了。他說
：

絕望之為虛妄，正與希望相同。

倘使我還得偷生在不明不暗的這“虛妄”中，我就還要尋求那逝去的悲涼漂渺的青春，
但不妨在我的身外。因為身外的青春倘一消滅，我身中的遲暮也即凋零了。

然而現在沒有星和月光，沒有僵墜的蝴蝶以至笑的渺茫，愛的翔舞。然而青年們很平安
。

我衹得由我來肉薄這空虛中的暗夜了，縱使尋不到身外的青春，也總得自己來一擲我身
中的遲暮。但暗夜又在那裡呢？現在沒有星，沒有月光以至沒有笑的渺茫和愛的翔舞；
青年們很平安，而我的面前又竟至於並且沒有真的暗夜。

絕望之為虛妄，正與希望相同！

雪

暖國的雨，向來沒有變過冰冷的堅硬的燦爛的雪花。博識的人們覺得他單調，他自己也
以為不幸否耶？江南的雪，可是滋潤美豔之至了；那是還在隱約著的青春的消息，是極
壯健的處子的皮膚。雪野中有血紅的寶珠山茶，白中隱青的單瓣梅花，深黃的磬口的蠟
梅花；雪下麵還有冷綠的雜草。蝴蝶確乎沒有；蜜蜂是否來採山茶花和梅花的蜜，我可
記不真切了。但我的眼前仿佛看見冬花開在雪野中，有許多蜜蜂們忙碌地飛著，也聽得
他們嗡嗡地鬧著。

孩子們呵著凍得通紅，象紫芽薑一般的小手，七八個一齊來塑雪羅漢。因為不成功，誰
的父親也來幫忙了。羅漢就塑得比孩子們高得多，雖然不過是上小下大的一堆，終於分
不清是壺盧還是羅漢，然而很潔白，很明艷，以自身的滋潤相粘結，整個地閃閃地生光
。孩子們用龍眼核給他做眼珠，又從誰的母親的脂粉奩中偷得胭脂來塗在嘴唇上。這回
確是一個大阿羅漢了。他也就目光灼灼地嘴唇通紅地坐在雪地堙C

第二天還有幾個孩子來訪問他；對了他拍手，點頭，嘻笑。但他終於獨自坐著了。晴天
又來消釋他的皮膚，寒夜又使他結一層冰，化作不透明的水晶模樣，連續的晴天又使他
成為不知道算什麼，而嘴上的胭脂也褪盡了。

但是，朔方的雪花在紛飛之後，卻永遠如粉，如沙，他們決不粘連，撒在屋上，地上，
枯草上，就是這樣。屋上的雪是早已就有消化了的，因為屋堜~人的火的溫熱。別的，
在晴天之下，旋風忽來，便蓬勃地奮飛，在日光中燦燦地生光，如包藏火焰的大霧，旋
轉而且升騰，彌漫太空，使太空旋轉而且升騰地閃爍。

在無邊的曠野上，在凜冽的天宇下，閃閃地旋轉升騰著的是雨的精魂……

是的，那是孤獨的雪，是死掉的雨，是雨的精魂。

風箏

北京的冬季，地上還有積雪，灰黑色的禿樹枝丫叉於晴朗的天空中，而遠處有一二風箏
浮動，在我是一種驚異和悲哀。

故鄉的風箏時節，是春二月，倘聽到沙沙的風輪聲，仰頭便能看見一個淡墨色的蟹風箏
或嫩藍色的蜈蚣風箏。還有寂寞的瓦片風箏，沒有風輪，又放得很低，伶仃地顯出憔悴
可憐的模樣。但此時地上的楊柳已經發芽，早的山桃也多吐蕾，和孩子們的天上的點綴
相照應，打成一片春日的溫和。我現在在哪裡呢？四面都還是嚴冬的肅殺，而久經訣別
的故鄉的久經逝去的春天，卻就在這天空中蕩漾了。

但我是向來不愛放風箏的，不但不愛，並且嫌惡它，因為我以為這是沒出息孩子所做的
玩藝。和我相反的是我的小兄弟，他那時大概十歲內外罷，多病，瘦得不堪，然而最喜
歡風箏，自己買不起，我又不許放，他衹得張著小嘴，呆看著空中出神，有時竟至於小
半日。遠處的蟹風箏突然落下來了，他驚呼；兩個瓦片風箏的纏繞解開了，他高興得跳
躍。他的這些，在我看來都是笑柄，可鄙的。

有一天，我忽然想起，似乎多日不很看見他了，但記得曾見他在後園拾枯竹。我恍然大
悟似的，便跑向少有人去的一間堆積雜物的小屋去，推開門，果然就在塵封的什物堆中
發現了他。他向著大方凳，坐在小凳上；便很驚惶地站了起來，失了色瑟縮著。大方凳
旁靠著一個蝴蝶風箏的竹骨，還沒有糊上紙，凳上是一對做眼睛用的小風輪，正用紅紙
條裝飾著，將要完工了。我在破獲秘密的滿足中，又很憤怒他的瞞了我的眼睛，這樣苦
心孤詣地來偷做沒出息孩子的玩藝。我即刻伸手摺斷了蝴蝶的一支翅骨，又將風輪擲在
地下，踏扁了。論長幼，論力氣，他是都敵不過我的，我當然得到完全的勝利，於是傲
然走出，留他絕望地站在小屋堙C後來他怎樣，我不知道，也沒有留心。

然而我的懲罰終於輪到了，在我們離別得很久之後，我已經是中年。我不幸偶而看到了
一本外國的講論兒童的書，才知道游戲是兒童最正當的行為，玩具是兒童的天使。於是
二十年來毫不憶及的幼小時候對於精神的虐殺的這一幕，忽地在眼前展開，而我的心也
仿佛同時變了鉛塊，很重很重地墜下去了。

但心又不竟墜下去而至於斷絕，它衹是很重很重地墜著，墜著。

我也知道補過的方法的：送他風箏，贊成他放，勸他放，我和他一同放。我們嚷著，跑
著，笑著——然而他其時已經和我一樣，早已有了鬍子了。

我也知道還有一個補過的方法的：去討他的寬恕，等他說，“我可是毫不怪你呵。”那
麼，我的心一定就輕鬆了，這確是一個可行的方法。有一回，我們會面的時候，是臉上
都已添刻了許多“生”的辛苦的條紋，而我的心很沉重。我們漸漸談起兒時的舊事來，
我便敘述到這一節，自說少年時代的糊塗。“我可是毫不怪你呵。”我想，他要說了，
我即刻便受了寬恕，我的心從此也寬鬆了罷。

“有過這樣的事麼？”他驚異地笑著說，就像旁聽著別人的故事一樣。他什麼也記不得
了。

全然忘卻，毫無怨恨，又有什麼寬恕可言呢？無怨的恕，說謊罷了。

我還能希求什麼呢？我的心衹得沉重著。

現在，故鄉的春天又在這異地的空中了，既給我久經逝去的兒時的回憶，而一併也帶著
無可把握的悲哀。我倒不如躲到肅殺的嚴冬中去罷，——但是，四面又明明是嚴冬，正
給我非常的寒威和冷氣。

好的故事

人睡到不知道時候的時候，就會有影來告別，說出那些話──

有我所不樂意的在地獄裡，我不願去；有我所不樂意的在地獄裡，我不願去；有我所不
樂意的在你們將來的黃金世界裡，我不願去。

然而你就是我所不樂意的。

朋友，我不想跟隨你，我不願住。

我不願意！

嗚乎嗚乎，我不願意，我不如彷徨於無地。

我不過一個影，要別你而沉沒在黑暗裡了。然而黑暗又會吞併我，然而光明又會使我消
失。

然而我不願彷徨於明暗之間，我不如在黑暗裡沉沒。

然而我終於彷徨於明暗之間，我不知道是黃昏還是黎明。我姑且舉灰黑的手裝作喝幹一
杯酒，我將在不知道時候的時候獨自遠行。

嗚乎嗚乎，倘若黃昏，黑夜自然會來沉沒我，否則我要被白天消失，如果現是黎明。

朋友，時候近了。

我將向黑暗裡彷徨於無地。

你還想我的贈品。我能獻你甚麼呢？無已，則仍是黑暗和虛空而已。但是，我願意只是
黑暗，或者會消失於你的白天；我願意只是虛，決不占你的心地。

我願意這樣，朋友──

我獨自遠行，不但沒有你，並且再沒有別的影在黑暗裡。只有我被黑暗沉沒，那世界全
屬於我自己。

過客

時：或一日的黃昏

地：或一處

人：

老翁——約七十歲，白頭髮，黑長袍。

女孩——約十歲，紫發，烏眼珠，白地黑方格長衫。

過客——約三四十歲，狀態困頓倔強，眼光陰沉，黑須，亂髮，黑色短衣褲皆破碎，赤
足著破鞋，脅下掛一個口袋，支著等身的竹杖。

東，是幾株雜樹和瓦礫；西，是荒涼破敗的叢葬；其間有一條似路非路的痕跡。一間小
土屋向這痕跡開著一扇門；門側有一段枯樹根。

〔女孩正要將坐在樹根上的老翁攙起。〕

翁——孩子。喂，孩子！怎麼不動了呢？

孩——〔向東望著，〕有誰走來了，看一看罷。

翁——不用看他。扶我進去罷。太陽要下去了。

孩——我，——看一看。

翁——唉，你這孩子！天天看見天，看見土，看見風，還不夠好看麼？什麼也不比這些
好看。你偏是要看誰。太陽下去時候出現的東西，不會給你什麼好處的。……還是進去
罷。

孩——可是，已經近來了。阿阿，是一個乞丐。

翁——乞丐？不見得罷。

〔過客從東面的雜樹間蹌踉走出，暫時躊躇之後，慢慢地走近老翁去。〕

客——老丈，你晚上好？

翁——阿，好！托福。你好？

客——老丈，我實在冒昧，我想在你那裡討一杯水喝。我走得渴極了。這地方又沒有一
個池塘，一個水窪。

翁——唔，可以可以。你請坐罷。〔向女孩，〕孩子，你拿水來，杯子要洗幹凈。

〔女孩默默地走進土屋去。〕

翁——客官，你請坐。你是怎麼稱呼的。

客——稱呼？——我不知道。從我還能記得的時候起，我就衹一個人，我不知道我本來
叫什麼。我一路走，有時人們也隨便稱呼我，各式各樣，我也記不清楚了，況且相同的
稱呼也沒有聽到過第二回。

翁——阿阿。那麼，你是從哪裡來的呢？

客——〔略略遲疑，〕我不知道。從我還能記得的時候起，我就在這麼走。

翁——對了。那麼，我可以問你到哪裡去麼？

客——自然可以。——但是，我不知道。從我還能記得的時候起，我就在這麼走，要走
到一個地方去，這地方就在前面。我單記得走了許多路，現在來到這裡了。我接著就要
走向那邊去，〔西指，〕前面！

〔女孩小心地捧出一個木杯來，遞去。〕

客——〔接杯，〕多謝，姑娘。〔將水兩口喝盡，還杯，〕多謝，姑娘。這真是少有的
好意。我真不知道應該怎樣感謝！

翁——不要這麼感激。這於你是沒有好處的。

客——是的，這於我沒有好處。可是我現在很恢復了些力氣了。我就要前去。老丈，你
大約是久住在這裡的，你可知道前面是怎麼一個所在麼？

翁——前面？前面，是墳。

客——〔詫異地，〕墳？

孩——不，不，不。那裡有許多許多野百合，野薔薇，我常常去玩，去看他們的。

客——〔西顧，仿佛微笑，〕不錯。那些地方有許多許多野百合，野薔薇，我也常常去
玩過，去看過的。但是，那是墳。〔向老翁，〕老丈，走完了那墳地之後呢？

翁——走完之後？那我可不知道。我沒有走過。

客——不知道？！

孩——我也不知道。

翁——我單知道南邊；北邊；東邊，你的來路。那是我最熟悉的地方，也許倒是於你們
最好的地方。你莫怪我多嘴，據我看來，你已經這麼勞頓了，還不如回轉去，因為你前
去也料不定可能走完。

客——料不定可能走完？……〔沉思，忽然驚起〕那不行！我衹得走。回到那裡去，就
沒一處沒有名目，沒一處沒有地主，沒一處沒有驅逐和牢籠，沒一處沒有皮面的笑容，
沒一處沒有眶外的眼淚。我憎惡他們，我不回轉去。

翁——那也不然。你也會遇見心底的眼淚，為你的悲哀。

客——不。我不願看見他們心底的眼淚，不要他們為我的悲哀。

翁——那麼，你，〔搖頭，〕你衹得走了。

客——是的，我衹得走了。況且還有聲音常在前面催促我，叫喚我，使我息不下。可恨
的是我的腳早經走破了，有許多傷，流了許多血。〔舉起一足給老人看，〕因此，我的
血不夠了；我要喝些血。但血在哪裡呢？可是我也不願意喝無論誰的血。我衹得喝些水
，來補充我的血。一路上總有水，我倒也並不感到什麼不足。衹是我的力氣太稀薄了，
血堶惜茼h了水的緣故罷。今天連一個小水窪也遇不到，也就是少走了路的緣故罷。

翁——那也未必。太陽下去了，我想，還不如休息一會的好罷，象我似的。

客——但是，那前面的聲音叫我走。

翁——我知道。

客——你知道？你知道那聲音麼？

翁——是的。他似乎曾經也叫過我。

客——那也就是現在叫我的聲音麼？

翁——那我可不知道。他也就是叫過幾聲，我不理他，他也就不叫了，我也就記不清楚
了。

客——唉唉，不理他……。〔沉思，忽然吃驚，傾聽著，〕不行！我還是走的好。我息
不下。可恨我的腳早經走破了。〔準備走路。〕

孩——給你！〔遞給一片布，〕裹上你的傷去。

客——多謝，〔接取，〕姑娘。這真是……。這真是極少有的好意。這能使我可以走更
多的路。〔就斷磚坐下，要將布纏在踝上，〕但是，不行！〔竭力站起，〕姑娘，還了
你罷，還是裹不下。況且這太多的好意，我沒法感激。

翁——你不要這麼感激，這於你沒有好處。

客——是的，這於我沒有什麼好處。但在我，這佈施是最上的東西了。你看，我全身上
可有這樣的。

翁——你不要當真就是。

客——是的。但是我不能。我怕我會這樣：倘使我得到了誰的佈施，我就要象兀鷹看見
死屍一樣，在四近徘徊，祝願她的滅亡，給我親自看見；或者咒詛她以外的一切全都滅
亡，連我自己，因為我就應該得到咒詛。但是我還沒有這樣的力量；即使有這力量，我
也不願意她有這樣的境遇，因為她們大概總不願意有這樣的境遇。我想，這最穩當。〔
向女孩，〕姑娘，你這布片太好，可是太小一點了，還了你罷。

孩——〔驚懼，退後，〕我不要了！你帶走！

客——〔似笑，〕哦哦，……因為我拿過了？

孩——〔點頭，指口袋，〕你裝在那裡，去玩玩。

客——〔頹唐地退後，〕但這背在身上，怎麼走呢？……

翁——你息不下，也就背不動。——休息一會，就沒有什麼了。

客——對咧，休息……。〔但忽然驚醒，傾聽。〕不，我不能！我還是走好。

翁——你總不願意休息麼？

客——我願意休息。

翁——那麼，你就休息一會罷。

客——但是，我不能……。

翁——你總還是覺得走好麼？

客——是的。還是走好。

翁——那麼，你還是走好罷。

客——〔將腰一伸，〕好，我告別了。我很感激你們。〔向著女孩，〕姑娘，這還你，
請你收回去。

〔女孩驚懼，斂手，要躲進土屋堨h。〕

翁——你帶去罷。要是太重了，可以隨時拋在墳地堶悸滿C

孩——〔走向前，〕阿阿，那不行！

客——阿阿，那不行的。

翁——那麼，你掛在野百合野薔薇上就是了。

孩——〔拍手，〕哈哈！好！

翁——哦哦……

〔極暫時中，沉默。〕

翁——那麼，再見了。祝你平安。〔站起，向女孩，〕孩子，扶我進去罷。你看，太陽
早已下去了。〔轉身向門。〕

客——多謝你們。祝你們平安。〔徘徊，沉思，忽然吃驚，〕然而我不能！我衹得走。
我還是走好罷……。〔即刻昂了頭，奮然向西走去。〕

〔女孩扶老人走進土屋，隨即關了門。過客向野地崲曆W地闖進去，夜色跟在他後面。
〕

死火

我夢見自己在冰山間奔馳。

這是高大的冰山，上接冰天，天上凍雲彌漫，片片如魚鱗模樣。山麓有冰樹林，枝葉都
如鬆杉。一切冰冷，一切青白。

但我忽然墜在冰谷中。

上下四旁無不冰冷，青白。而一切青白冰上，卻有紅影無數，糾結如珊瑚網。我俯看腳
下，有火焰在。

這是死火。有炎炎的形，但毫不搖動，全體冰結，象珊瑚枝；尖端還有凝固的黑煙，疑
這才從火宅中出，所以枯焦。這樣，映在冰的四壁，而且互相反映，化成無量數影，使
這冰谷，成紅珊瑚色。

哈哈！

當我幼小的時候，本就愛看快艦激起的浪花，洪爐噴出的烈焰。不但愛看，還想看清。
可惜他們都息息變幻，永無定形。雖然凝視又凝視，總不留下怎樣一定的跡象。

死的火焰，現在先得到了你了！
　　
我拾起死火，正要細看，那冷氣已使我的指頭焦灼；但是，我還熬著，將他塞入衣袋中
間。冰谷四面，登時完全青白。我一面思索著走出冰谷的法子。

我的身上噴出一縷黑煙，上升如鐵線蛇。冰谷四面，又登時滿有紅焰流動，如大火聚，
將我包圍。我低頭一看，死火已經燃燒，燒穿了我的衣裳，流在冰地上了。

“唉，朋友！你用了你的溫熱，將我驚醒了。”他說。

我連忙和他招呼，問他名姓。

“我原先被人遺棄在冰谷中，”他答非所問地說，“遺棄我的早已滅亡，消盡了。我也
被冰凍凍得要死。倘使你不給我溫熱，使我重行燒起，我不久就須滅亡。”

“你的醒來，使我歡喜。我正在想著走出冰谷的方法；我願意攜帶你去，使你永不冰結
，永得燃燒。”

“唉唉！那麼，我將燒完！”

“你的燒完，使我惋惜。我便將你留下，仍在這裡罷。”

“唉唉！那麼，我將凍滅了！”

“那麼，怎麼辦呢？”

“但你自己，又怎麼辦呢？”他反而問。

“我說過了：我要出這冰谷……”

“那我就不如燒完！”

他忽而躍起，如紅慧星，並我都出冰谷口外。有大石車突然馳來，我終於碾死在車輪底
下，但我還來得及看見那車墜入冰谷中。

“哈哈！你們是再也遇不著死火了！”我得意地笑著說，仿佛就願意這樣似的。

狗的駁詰

我夢見自己在隘巷中行走，衣履破碎，象乞食者。

一條狗在背後叫起來了。

我傲慢地回顧，叱﹛說：

“呔！住口！你這勢力的狗！”

“嘻嘻！”他笑了，還接著說，“不敢，愧不如人呢。”

“什麼！？”我氣憤了，覺得這是一個極端的侮辱。

“我慚愧：我終於還不知道分別銅和銀；還不知道分別布和綢；還不知道分別官和民；
還不知道分別主和奴；還不知道……”

我逃走了。

“且慢！我們再談談……”他在後面大聲輓留。

我一徑逃走，盡力地走，直到逃出夢境，躺在自己的床上。

失掉的好地獄

我夢見自己躺在床上，在荒寒的野外，地獄的旁邊。一切鬼魂們的叫喚無不低微，然有
秩序，與火焰的怒吼，油的沸騰，鋼叉的震顫相和鳴，造成醉心的大樂，佈告三界：天
下太平。

有一個偉大的男子站在我面前，美麗，慈悲，遍身有大光輝，然而我知道他是魔鬼。

“一切都已完結，一切都已完結！可憐的魔鬼們將那好的地獄失掉了！”他悲憤地說，
於是坐下，講給我一個他所知道的故事——

“天地作蜂蜜色的時候，就是魔鬼戰勝天神，掌握了主宰一切的大權威的時候。他收得
天國，收得人間，也收得地獄。他於是親臨地獄，坐在中央，遍身發大光輝，照見一切
鬼眾。

“地獄原已廢棄得很久了：劍樹消卻光芒；沸油的邊緣早不騰涌；大火聚有時不過冒些
青煙；遠處還萌生曼陀羅花，花極細小，慘白而可憐——那是不足為奇的，因為地上曾
經大被焚燒，自然失了他的肥沃。

“鬼魂們在冷油溫火媬籊荂A從魔鬼的光輝中看見地獄小花，慘白可憐，被大蠱惑，倏
忽間記起人世，默想至不知幾多年，遂同時向著人間，發一聲反獄的絕叫。

“人類便應聲而起，仗義直言，與魔鬼戰鬥。戰聲遍滿三界，遠過雷霆。終於運大謀略
，布大羅網，使魔鬼並且不得不從地獄出走。最後的勝利，是地獄門上也豎了人類的旌
旗！

“當魔鬼們一齊歡呼時，人類的整飭地獄使者已臨地獄，做在中央，用人類的威嚴，叱
﹛一切鬼眾。

“當鬼魂們又發出一聲反獄的絕叫時，即已成為人類的叛徒，得到永久沉淪的罰，遷入
劍樹林的中央。

“人類於是完全掌握了地獄的大威權，那威棱且在魔鬼以上。人類於是整頓廢弛，先給
牛首阿旁以最高的俸草；而且，添薪加火，磨礪刀山，使地獄全體改觀，一洗先前頹廢
的氣象。

“曼陀羅花立即焦枯了。油一樣沸；刀一樣﹛舌；火一樣熱；鬼眾一樣呻吟，一樣宛轉
，至於都不暇記起失掉的好地獄。

“這是人類的成功，是鬼魂的不幸……。

“朋友，你在猜疑我了。是的，你是人！我且去尋野獸和惡鬼……”

墓碣文

我夢見自己正和墓碣對立，讀上面的刻辭。那墓碣似是沙石所制，剝落很多，又有苔蘚
叢生，僅存有限的文句──……於浩歌狂熱之際中寒﹔於天上看見深淵。於一切眼中看
見無所有﹔於無所希望中得救。…………有一游魂，化為長蛇，口有毒牙。不以嚙人，
自嚙其身，終以殞顛。…………離開！……

我繞到碣後，才見孤墳，上無草木，且已頹壞。即從大闕口中，窺見死屍，胸腹俱破，
中無心肝。而臉上卻絕不顯哀樂之狀，但矇矇如煙然。

我在疑懼中不及回身，然而已看見墓碣陰面的殘存的文句──

……抉心自食，欲知本味。創痛酷烈，本味何能知？……

……痛定之後，徐徐食之。然其心已陳舊，本味又何由知？……

……答我。否則，離開！……我就要離開。而死屍已在墳中坐起，口脣不動，然而說─
─

待我成塵時，你將見我的微笑！”

我疾走，不敢反顧，生怕看見他的追隨。

頹敗線的顫動

我夢見自己在做夢。自身不知所在，眼前卻有一間在深夜中禁閉的小屋的內部，但也看
見屋上瓦鬆的茂密的森林。

板桌上的燈罩是新拭的，照得屋子堣壎~明亮。在光明中，在破榻上，在初不相識的披
毛的強悍的肉塊底下，有瘦弱渺小的身軀，為饑餓，苦痛，驚異，羞辱，歡欣而顫動。
弛緩，然而尚且豐腴的皮膚光潤了；青白的兩頰泛出輕紅，如鉛上塗了胭脂水。

燈火也因驚懼而縮小了，東方已經發白。

然而空中還彌漫地搖動著饑餓，苦痛，驚異，羞辱，歡欣的波濤……

“媽！”約略兩歲的女孩被門的開合聲驚醒，在草席圍著的屋角的地上叫起來了。

“還早哩，再睡一會罷！”她驚惶地說。

“媽！我餓，肚子痛。我們今天能有什麼吃的？”

“我們今天有吃的了。等一會有賣燒餅的來，媽就買給你。”她欣慰地更加緊捏著掌中
的小銀片，低微的聲音悲涼地發抖，走近屋角去一看她的女兒，移開草席，抱起來放在
破榻上。

“還早哩，再睡一會罷。”她說著，同時抬起眼睛，無可告訴地一看破舊屋頂以上的天
空。

空中突然另起了一個很大的波濤，和先前的相撞擊，迴旋而成旋渦，將一切並我盡行淹
沒，口鼻都不能呼吸。

我呻吟著醒來，窗外滿是如銀的月色，離天明還很遼遠似的。

我自身不知所在，眼前卻有一間在深夜中禁閉的小屋的內部，我自己知道是在續著殘夢
。可是夢的年代隔了許多年了。屋的內外已經是這樣整齊；堶惇O青年的夫妻，一群小
孩子，都怨恨鄙夷地對著一個垂老的女人。

“我們沒有臉見人，就衹因為你，”男人氣忿地說。“你還以為養大了她，其實正是害
苦了她，倒不如小時候餓死的好！”

“使我委屈一世的就是你！”女的說。

“還要帶累了我！”男的說。

“還要帶累他們哩！”女的說，指著孩子們。

最小的一個正玩著一片幹蘆葉，這時便向空中一揮，仿佛一柄鋼刀，大聲說道：“殺！
”

那垂老的女人口角正在痙攣，登時一怔，接著便都平靜，不多時候，她冷靜地，骨立的
石像似的站起來了。她開開板門，邁步在深夜中走出，遺棄了背後一切的冷罵和毒笑。

她在深夜中盡走，一直走到無邊的荒野；四面都是荒野，頭上衹有高天，並無一個蟲鳥
飛過。她赤身露體地，石像似的站在荒野的中央，於一剎那間照見過往的一切：饑餓，
苦痛，驚異，羞辱，歡欣，於是發抖；害苦，委屈，帶累，於是痙攣；殺，於是平靜。
……又於一剎那間將一切並合：眷念與決絕，愛撫與復仇，養育與殲除，祝福與咒詛。
……她於是舉兩手盡量向天，口唇間漏出人與獸的，非人間所有，所以無詞的言語。

當她說出無詞的言語時，她那偉大如石像，然而已經荒廢的，頹敗的身軀的全面都顫動
了。這顫動點點如魚鱗，仿佛暴風雨中的荒海的波濤。

她於是抬起眼睛向著天空，並無詞的言語也沉默盡絕，惟有顫動，輻射若太陽光，使空
中的波濤立刻迴旋，如遭颶風，洶湧奔騰於無邊的荒野。

我夢魘了，自己卻知道是因為將手擱在胸脯上了的緣故；我夢中還用盡平生之力，要將
這十分沉重的手移開。

立論

我夢見自己正在小學校的講堂上預備作文，向老師請教立論的方法。

“難！”老師從眼鏡圈外斜射出眼光來，看著我，說。“我告訴你一件事——

“一家人家生了一個男孩，合家高興透頂了。滿月的時候，抱出來給客人看，——大概
自然是想得一點好兆頭。

“一個說：‘這孩子將來要發財的。’他於是得到一番感謝。

“一個說：‘這孩子將來是要死的。’他於是得到一頓大家合力的痛打。

“說要死的必然，說富貴的許謊。但說謊的得好報，說必然的遭打。你……”

“我願意既不說謊，也不遭打。那麼，老師，我得怎麼說呢？”

“那麼，你得說：‘啊呀！這孩子呵！您瞧！那麼……。阿唷！哈哈！Hehe！he，he he
 he he！’”

死後

我夢見自己死在道路上。

這是那裡，我怎麼到這裡來，怎麼死的，這些事我全不明白。總之，待我自己知道已經
死掉的時候，就已經死在那裡了。

聽到幾聲喜鵲叫，接著是一陣烏老鴉。空氣很清爽，——雖然也帶些土氣息，——大約
正當黎明時候罷。我想睜開眼睛來，他卻絲毫也不動，簡直不象是我的眼睛；於是想抬
手，也一樣。

恐怖的利鏃忽然穿透我的心了。在我生存時，曾經玩笑地設想：假使一個人的死亡，衹
是運動神經的廢滅，而知覺還在，那就比全死了更可怕。誰知道我的預想竟的中了，我
自己就在證實這預想。

聽到腳步聲，走路的罷。一輛獨輪車從我的頭邊推過，大約是重載的，軋軋地叫得人心
煩，還有些牙齒﹛齒楚﹛。很覺得滿眼緋紅，一定是太陽上來了。那麼，我的臉是朝東
的。但那都沒有什麼關係。切切嚓嚓的人聲，看熱鬧的。他們踹起黃土來，飛進我的鼻
孔，使我想打噴嚏了，但終於沒有打，僅有想打的心。

陸陸續續地又是腳步聲，都到近旁就停下，還有更多的低語聲：看的人多起來了。我忽
然很想聽聽他們的議論。但同時想，我生存時說的什麼批評不值一笑的話，大概是違心
之論罷：才死，就露了破綻了。然而還是聽；然而畢竟得不到結論，歸納起來不過是這
樣——

“死了……”

“嗡。——這……”

“哼！……”

“嘖。……唉！……”

我十分高興，因為始終沒有聽到一個熟識的聲音。否則，或者害得他們傷心；或則要使
他們快意；或則要使他們添些飯後閑談的材料，多破費寶貴的工夫；這都會使我很抱歉
。現在誰也看不見，就是誰也不受影響。好了，總算對得起人了！

但是，大約是一個馬蟻，在我的脊梁上爬著，癢癢的。我一點也不能動，已經沒有除去
他的能力了；倘在平時，衹將身子一扭，就能使他退避。而且，大腿上又爬著一個哩！
你們是做什麼的？蟲豸！

事情可更壞了：嗡的一聲，就有一個青蠅停在我的顴骨上，走了幾步，又一飛，開口便
舐我的鼻尖。我懊惱地想：足下，我不是什麼偉人，你無須到我身上來尋做論的材料…
…。但是不能說出來。他卻從鼻尖跑下，又用冷舌頭來舐我的嘴唇了，不知道可是表示
親愛。還有幾個則聚在眉毛上，跨一步，我的毛根就一搖。實在使我煩厭得不堪，——
不堪之至。

忽然，一陣風，一片東西從上面蓋下來，他們就一同飛開了，臨走時還說——

“惜哉！……”

我憤怒得幾乎昏厥過去。

木材摔在地上的鈍重的聲音同著地面的震動，使我忽然清醒，前額上感著蘆席的條紋。
但那蘆席就被掀去了，又立刻感到了日光的灼熱。還聽得有人說——

“怎麼要死在這裡？……”

這聲音離我很近，他正彎著腰罷。但人應該死在那裡呢？我先前以為人在地上雖沒有任
意生存的權利，卻總有任意死掉的權利的。現在才知道並不然，也很難適合人們的公意
。可惜我久沒了紙筆；即有也不能寫，而且即使寫了也沒有地方發表了。衹好就這樣拋
開。

有人來抬我，也不知道是誰。聽到刀鞘聲，還有巡警在這裡罷，在我所不應該“死在這
裡”的這裡。我被翻了幾個轉身，便覺得向上一舉，又往下一沉；又聽得蓋了蓋，釘著
釘。但是，奇怪，衹釘了兩個。難道這裡的棺材釘，是釘兩個的麼？

我想：這回是六面碰壁，外加釘子。真是完全失敗，嗚呼哀哉了！……

“氣悶！……”我又想。

然而我其實卻比先前已經寧靜得多，雖然知不清埋了沒有。在手背上觸到草席的條紋，
覺得這屍衾倒也不惡。衹不知道是誰給我化錢的，可惜！但是，可惡，收斂的小子們！
我背後的小衫的一角皺起來了，他們並不給我拉平，現在抵得我很難受。你們以為死人
無知，做事就這樣地草率？哈哈！

我的身體似乎比活的時候要重得多，所以壓著衣皺便格外的不舒服。但我想，不久就可
以習慣的；或者就要腐爛，不至於再有什麼大麻煩。此刻還不如靜靜地靜著想。

“您好？您死了麼？”

是一個頗為耳熟的聲音。睜眼看時，卻是勃古齋舊書鋪的跑外的小伙計。不見約有二十
多年了，倒還是一副老樣子。我又看看六面的壁，委實太毛糙，簡直毫沒有加過一點修
刮，鋸絨還是毛毿毿的。

“那不礙事，那不要緊。”他說，一面打開暗藍色布的包裹來。“這是明板《公羊傳》
，嘉靖黑口本，給您送來了。您留下他罷。這是……”

“你！”我詫異地看定他的眼睛，說，“你莫非真正胡塗了？你看我這模樣，還要看什
麼明板？……”

“那可以看，那不礙事。”

我即刻閉上眼睛，因為對他很煩厭。停了一會，沒有聲息，他大約走了。但是似乎一個
馬蟻又在脖子上爬起來，終於爬到臉上，衹繞著眼眶轉圈子。

萬不料人的思想，是死掉之後也會變化的。忽而，有一種力將我的心的平安衝破；同時
，許多夢也都做在眼前了。幾個朋友祝我安樂，幾個仇敵祝我滅亡。我卻總是既不安樂
，也不滅亡地不上不下地生活下來，都不能副任何一面的期望。現在又影一般死掉了，
連仇敵也不使知道，不肯贈給他們一點惠而不費的歡欣。……

我覺得在快意中要哭出來。這大概是我死後第一次的哭。

然而終於也沒有眼淚流下；衹看見眼前仿佛有火花一樣，我於是坐了起來。

這樣的戰士

要有這樣的一種戰士——

已不是蒙昧如非洲土人而背著雪亮的毛瑟槍的；也並不疲憊如中國綠營兵而卻佩著盒子
炮。他毫無乞靈於牛皮和廢鐵的甲胄；他衹有自己，但拿著蠻人所用的，脫手一擲的投
槍。

他走進無物之陣，所遇見的都對他一式點頭。他知道這點頭就是敵人的武器，是殺人不
見血的武器，許多戰士都在此滅亡，正如炮彈一般，使猛士無所用其力。

那些頭上有各種旗幟，繡出各樣好名稱：慈善家，學者，文士，長者，青年，雅人，君
子……。頭下有各樣外套，繡出各式好花樣：學問，道德，國粹，民意，邏輯，公義，
東方文明……

但他舉起了投槍。

他們都同聲立了誓來講說，他們的心都在胸膛的中央，和別的偏心的人類兩樣。他們都
在胸前放著護心鏡，就為自己也深信在胸膛中央的事作證。

但他舉起了投槍。

他微笑，偏側一擲，卻正中了他們的心窩。

一切都頹然倒地；——然而衹有一件外套，其中無物。無物之物已經脫走，得了勝利，
因為他這時成了戕害慈善家等類的罪人。

但他舉起了投槍。

他在無物之陣中大踏步走，再見一式的點頭，各種的旗幟，各樣的外套……

但他舉起了投槍。

他終於在無物之陣中老衰，壽終。他終於不是戰士，但無物之物則是勝者。

在這樣的境地裏，誰也不聞戰叫：太平。

太平……。

但他舉起了投槍！

聰明人和傻子和奴才

奴才總不過是尋人訴苦。衹要這樣，也衹能這樣。有一日，他遇到一個聰明人。

“先生！”他悲哀地說，眼淚聯成一線，就從眼角上直流下來。“你知道的。我所過的
簡直不是人的生活。吃的是一天未必有一餐，這一餐又不過是高粱皮，連豬狗都不要吃
的，尚且衹有一小碗……”

“這實在令人同情。”聰明人也慘然說。

“可不是麼！”他高興了。“可是做工是晝夜無休息：清早擔水晚燒飯，上午跑街夜磨
面，晴洗衣裳雨張傘，冬燒汽爐夏打扇。半夜要煨銀耳，侍候主人耍錢；頭錢從來沒分
，有時還挨皮鞭……。”

“唉唉……”聰明人嘆息著，眼圈有些發紅，似乎要下淚。

“先生！我這樣是敷衍不下去的。我總得另外想法子。可是什麼法子呢？……”

“我想，你總會好起來……”

“是麼？但願如此。可是我對先生訴了冤苦，又得你的同情和慰安，已經舒坦得不少了
。可見天理沒有滅絕……”

但是，不幾日，他又不平起來了，仍然尋人去訴苦。

“先生！”他流著眼淚說，“你知道的。我住的簡直比豬窩還不如。主人並不將我當人
；他對他的叭兒狗還要好到幾萬倍……”

“混帳！”那人大叫起來，使他吃驚了。那人是一個傻子。

“先生，我住的衹是一間破小屋，又濕，又陰，滿是臭蟲，睡下去就咬得真可以。穢氣
衝著鼻子，四面又沒有一個窗子……”

“你不會要你的主人開一個窗的麼？”

“這怎麼行？……”

“那麼，你帶我去看去！”

傻子跟奴才到他屋外，動手就砸那泥晼C

“先生！你幹什麼？”他大驚地說。

“我給你打開一個窗洞來。”

“這不行！主人要罵的！”

“管他呢！”他仍然砸。

“人來呀！強盜在毀咱們的屋子了！快來呀！遲一點可要打出窟窿來了！……”他哭嚷
著，在地上團團地打滾。

一群奴才都出來，將傻子趕走。

聽到了喊聲，慢慢地最後出來的是主人。

“有強盜要來毀咱們的屋子，我首先叫喊起來，大家一同把他趕走了。”他恭敬而得勝
地說。

“你不錯。”主人這樣誇獎他。

這一天就來了許多慰問的人，聰明人也在內。

“先生。這回因為我有功，主人誇獎了我了。你先前說我總會好起來，實在是有先見之
明……。”他大有希望似的高興地說。

“可不是麼……”聰明人也代為高興似的回答他。

臘葉

燈下看《雁門集》，忽然翻出一片壓幹的楓葉來。

這使我記起去年的深秋。繁霜夜降，木葉多半凋零，庭前的一株小小的楓樹也變成紅色
了。我曾繞樹徘徊，細看葉片的顏色，當他青蔥的時候是從沒有這麼註意的。他也並非
全樹通紅，最多的是淺絳，有幾片則在緋紅地上，還帶著幾團濃綠。一片獨有一點蛀孔
，鑲著烏黑的花邊，在紅，黃和綠的斑駁中，明眸似的向人凝視。我自念：這是病葉呵
！便將他摘了下來，夾在剛才買到的《雁門集》堙C大概是願使這將墜的被蝕而斑斕的
顏色，暫得保存，不即與群葉一同飄散罷。

但今夜他卻黃蠟似的躺在我的眼前，那眸子也不復似去年一般灼灼。假使再過幾年，舊
時的顏色在我記憶中消去，怕連我也不知道他何以夾在書堶悸滬鴞]了。將墜的病葉的
斑斕，似乎也衹能在極短時中相對，更何況是蔥鬱的呢。看看窗外，很能耐寒的樹木也
早經禿盡了；楓樹更何消說得。當深秋時，想來也許有和這去年的模樣相似的病葉罷，
但可惜我今年竟沒有賞玩秋樹的餘閑。

淡淡的血痕中

—紀念幾個死者和生者和未生者—

目前的造物主，還是一個怯弱者。

他暗暗地使天地變異，卻不敢毀滅一個這地球；暗暗地使生物衰亡，卻不敢長存一切屍
體；暗暗地使人類流血，卻不敢使血色永遠鮮濃；暗暗地使人類受苦，卻不敢使人類永
遠記得。

他專為他的同類——人類中的怯弱者——設想，用廢墟荒墳來襯托華屋，用時光來衝淡
苦痛和血痕；日日斟出一杯微甘的苦酒，不太少，不太多，以能微醉為度，遞給人間，
使飲者可以哭，可以歌，也如醒，也如醉，若有知，若無知，也欲死，也欲生。他必須
使一切也欲生；他還沒有滅盡人類的勇氣。

幾片廢墟和幾個荒墳散在地上，映以淡淡的血痕，人們都在其間咀嚼著人我的渺茫的悲
苦。但是不肯吐棄，以為究竟勝於空虛，各各自稱為“天之戮民”，以作咀嚼著人我的
渺茫的悲苦的辯解，而且悚息著靜待新的悲苦的到來。新的，這就使他們恐懼，而又渴
欲相遇。

這都是造物主的良民。他就需要這樣。

叛逆的猛士出於人間；他屹立著，洞見一切已改和現有的廢墟和荒墳，記得一切深廣和
久遠的苦痛，正視一切重疊淤積的凝血，深知一切已死，方生，將生和未生。他看透了
造化的把戲；他將要起來使人類蘇生，或者使人類滅盡，這些造物主的良民們。

造物主，怯弱者，羞慚了，於是伏藏。天地在猛士的眼中於是變色。

一覺

飛機負了擲下炸彈的使命，象學校的上課似的，每日上午在北京城上飛行。每聽得機件
搏擊空氣的聲音，我常覺到一種輕微的緊張，宛然目睹了“死”的襲來，但同時也深切
地感著“生”的存在。

隱約聽到一二爆發聲以後，飛機嗡嗡地叫著，冉冉地飛去了。也許有人死傷了罷，然而
天下卻似乎更顯得太平。窗外的白楊的嫩葉，在日光下發烏金光；榆葉梅也比昨日開得
更爛漫。收拾了散亂滿床的日報，拂去昨夜聚在書桌上的蒼白的微塵，我的四方的小書
齋，今日也依然是所謂“窗明幾淨”。

因為或一種原因，我開手編校那歷來積壓在我這裡的青年作者的文稿了；我要全都給一
個清理。我照作品的年月看下去，這些不肯塗脂抹粉的青年們的魂靈便依次屹立在我眼
前。他們是綽約的，是純真的，——呵，然而他們苦惱了，呻吟了，憤怒了，而且終於
粗暴了，我的可愛的青年們。

魂靈被風沙打擊得粗暴，因為這是人的魂靈，我愛這樣的魂靈；我願意在無形無色的鮮
血淋漓的粗暴上接吻。漂渺的名園中，奇花盛開著，紅顏的靜女正在超然無事地逍遙，
鶴唳一聲，白雲鬱然而起……。這自然使人神往的罷，然而我總記得我活在人間。

我忽然記起一件事：兩三年前，我在北京大學的教員預備室堙A看見進來一個並不熟悉
的青年，默默地給我一包書，便出去了，打開看時，是一本《淺草》。就在這默默中，
使我懂得了許多話。阿，這贈品是多麼豐饒呵！可惜那《淺草》不再出版了，似乎衹成
了《沉鐘》的前身。那《沉鐘》就在這風沙﹛項洞中，深深地在人海的底堭I寞地鳴動
。

野薊經了幾乎致命的摧折，還要開一朵小花，我記得托爾斯泰曾受了很大的感動，因此
寫出一篇小說來。但是，草木在旱幹的沙漠中間，拼命伸長他的根，吸取深地中的水泉
，來造成碧綠的林莽，自然是為了自己的“生”的，然而使疲勞枯渴的旅人，一見就怡
然覺得遇到了暫時息肩之所，這是如何的可以感激，而且可以悲哀的事？！

《沉鐘》的《無題》——代啟事——說：“有人說：我們的社會是一片沙漠。——如果
當真是一片沙漠，這雖然荒漠一點也還靜肅；雖然寂寞一點也還會使你感覺蒼茫。何至
於象這樣的混沌，這樣的陰沉，而且這樣的離奇變幻！”

是的，青年的魂靈屹立在我眼前，他們已經粗暴了，或者將要粗暴了，然而我愛這些流
血和隱痛的魂靈，因為他使我覺得是在人間，是在人間活著。

在編校中夕陽居然西下，燈火給我接續的光。各樣的青春在眼前一一馳去了，身外但有
昏黃環繞。我疲勞著，捏著紙煙，在無名的思想中靜靜地合了眼睛，看見很長的夢。忽
而警覺，身外也還是環繞著昏黃；煙篆在不動的空氣中飛升，如幾片小小夏雲，徐徐幻
出難以指名的形象。
