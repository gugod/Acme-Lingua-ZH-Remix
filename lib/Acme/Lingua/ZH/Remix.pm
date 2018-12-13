package Acme::Lingua::ZH::Remix;
use v5.10;
our $VERSION = "0.97";

=pod

=encoding utf8

=head1 NAME

Acme::Lingua::ZH::Remix - The Chinese sentence generator.

=head1 SYNOPSIS

    use Acme::Lingua::ZH::Remix;

    my $x = Acme::Lingua::ZH::Remix->new;

    # Generate a random sentance
    say $x->random_sentence;

=head1 DESCRIPTION

Because lipsum is not funny enough, that is the reason to write this
module.

This module is a L<Moose> based OO module. You create an instance of
it with C<new> method, and then invoke methods on the returned object.

The C<random_sentence> method returns a string of one sentence
of Chinese like:

    真是完全失敗，孩子！怎麼不動了呢？

It uses the corpus data from Project Gutenberg by default. All
generate sentences are remixes of the corpus.

You can feed you own corpus data to the `feed` method:

    my $x = Acme::Lingua::ZH::Remix->new;
    $x->feed($my_corpus);

    # Say something based on $my_corpus
    say $x->random_santence;

The corpus should use full-width punctuation characters.

=cut

use utf8;
use Moose;
use Types::Standard qw(HashRef Int);
use List::MoreUtils qw(uniq);
use Hash::Merge qw(merge);

has phrases      => (is => "rw", isa => HashRef, lazy_build => 1);
has phrase_count => (is => "rw", isa => Int, lazy_build => 1);

sub _build_phrases {
    my $self   = shift;
    local $/   = undef;
    my $corpus = <DATA>;
    my %phrase;
    my @phrases = $self->split_corpus($corpus);
    for (@phrases) {
        my $p = substr($_, -1);
        push @{$phrase{$p} ||=[]}, \$_;
    }
    return \%phrase;
}

sub _build_phrase_count {
    my $self = shift;
    my %p = %{$self->phrases};
    my $count = 0;
    for(keys %p) {
        $count += scalar @{$p{$_}};
    }
    return $count;
}

sub random(@) { $_[ rand @_ ] }

=head1 METHODS

=head2 split_corpus($corpus_text)

Takes a scalar, returns an list.

This is an utility method that does not change the internal state of
the topic object.

=cut

sub split_corpus {
    my ($self, $corpus) = @_;
    return () unless $corpus;

    $corpus =~ s/^\#.*$//gm;

    # Squeeze whitespaces
    $corpus =~ s/(\s|　)*//gs;

    # Ignore certain punctuations
    $corpus =~ s/(——|──)//gs;

    my @xc = split /(?:（(.+?)）|：?「(.+?)」|〔(.+?)〕|“(.+?)”)/, $corpus;
    my @phrases = uniq sort grep /.(，|。|？|！)$/,
        map {
            my @x = split /(，|。|？|！)/, $_;
            my @r = ();
            while (@x) {
                my $s = shift @x;
                my $p = shift @x or next;

                $s =~ s/^(，|。|？|！|\s)+//;
                push @r, "$s$p";
            }
            @r;
        } map {
            s/^\s+//;
            s/\s+$//;
            s/^(.+?) //;
            $_;
        } grep { $_ } @xc;

    return @phrases;
}

=head2 feed($corpus_text)

Instance method. Takes a scalar, return the topic object.

Merge C<$corpus_text> into the internal phrases corpus of the object.

=cut

sub feed {
    my $self   = shift;
    my $corpus = shift;

    my %phrase;
    my @phrases = $self->split_corpus($corpus);

    for (@phrases) {
        my $p = substr($_, -1);
        push @{$phrase{$p} ||=[]}, \$_;
    }

    $self->phrases(merge($self->phrases, \%phrase));
    $self->phrase_count( $self->_build_phrase_count );

    return $self;
}

sub phrase_ratio {
    my $self = shift;
    my $type = shift;
    my $phrases = $self->phrases->{$type}||=[];
    my $count   = $self->phrase_count;
    return 0 if $count == 0;
    return @{$phrases} / $count;
}

sub random_phrase {
    my $self = shift;
    my $type = shift;

    return ${ random(@{ $self->phrases->{$type}||=[] }) || \'' };
}

=head2 random_sentence( min => $min, max => $max )

Instance method. Optionally takes "min" or "max" parameter as the constraint of
sentence length (number of characters).

Both min and max values are required to be integers greater or equal to
zero. The value of max should be greater then the value of min. If any of these
values are invalidate, it is treated as if they are not passed.

The default values of min, max are 0 and 140, respectively.

The implementation random algorthm based, thus it needs indefinite time to
generate the result. If it takes more then 1000 iterations, it aborts and return
the results anyway, regardless the length constraint. This can happen when the
lengths of phrases from corpus do no adds up to a value within the given range.

The returned scalar is the generate sentence string of wide characters. (Which
makes Encode::is_utf8 return true.)

=cut

sub random_sentence {
    my ($self, %options) = @_;

    for my $p (qw(min max)) {
        my $x = $options{$p};
        unless (defined($x) && int($x) eq $x && $x >= 0) {
            delete $options{$p}
        }
    }

    if (defined($options{max}) && defined($options{min}) && $options{max} < $options{min}) {
        delete $options{max};
        delete $options{min};
    }

    $options{min} ||= 0;
    $options{max} ||= 140;

    my $str = "";
    my @phrases;

    my $ending = $self->random_phrase(random(qw/。 ！ ？/)) || "…";

    while ( length($ending) > $options{max} ) {
        $ending = $self->random_phrase(random(qw/。 ！ ？/)) || "…";
    }

    unshift @phrases, $ending;

    my $l = length($ending);

    my $iterations = 0;
    my $max_iterations = 1000;
    my $average = ($options{min} + $options{max}) / 2;
    my $desired = int(rand($options{max} - $options{min}) + $options{min}) || $average || $options{max};

    while ($iterations++ < $max_iterations) {
        my $x;
        do {
            $x = random('，', '」', '）', '/')
        } while ($self->phrase_ratio($x) == 0);

        my $p = $self->random_phrase($x);

         if ($l + length($p) < $options{max}) {
            unshift @phrases, $p;
            $l += length($p);
        }

        my $r = abs(1 - $l/$desired);
        last if $r < 0.1;
        last if $r < 0.2 && $iterations >= $max_iterations/2;
    }

    $str = join "", @phrases;
    $str =~ s/，$//;
    $str =~ s/^「(.+)」$/$1/;

    if (rand > 0.5) {
        $str =~ s/(，)……/$1/gs;
    } else {
        $str =~ s/，(……)/$1/gs;
    }

    return $str;
}

1;

=head1 AUTHOR

Kang-min Liu <gugod@gugod.org>

=head1 COPYRIGHT

Copyright 2010- by Kang-min Liu, <gugod@gugod.org>

This program is free software; you can redistribute it a nd/or modify
it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

# Data coming from Wikisource
# http://zh.wikisource.org/zh-hant/%E5%BF%98%E4%B8%8D%E4%BA%86%E7%9A%84%E9%81%8E%E5%B9%B4

__DATA__
#c9s

還不賴，還不賴。還不賴！還不賴？

# 前進

在一個晚上，是黑暗的晚上，暗黑的氣氛，濃濃密密把空間充塞著，不讓星星的光明，漏射到地上。那黑暗雖在幾百層的地底，也是經驗不到，是未曾有過駭人的黑暗。

　　在這被黑暗所充塞的地上，有倆個被時代母親所遺棄的孩童。他倆的來歷有些不明，不曉得是追慕不返母親的慈愛，自己走出家來，也是不受後母教訓，被逐的前人之子。

　　他倆不知立的什麼地方，也不知什麼是方向，不知立的地面是否穩固，也不知立的四周是否危險，因為一片暗黑，眼睛已失了作用。

　　他倆已經忘卻了一切，心裡不懷抱驚恐，也不希求慰安；只有一種的直覺支配著他們，──前進！

　　他倆感到有一種，不許他們永久立存同一位置的勢力。他倆便也攜著手，堅固地信賴、互相提攜；由本能的衝動，向面的所向，那不知去處的前途，移動自己的腳步。前進！盲目地前進！

無目的地前進！自然忘記他們行程的遠近，只是前進，互相信賴，互相提攜，為著前進而前進。

　　他倆沒有尋求光明之路的意識，也沒有走到自由之路的慾望，只是望面的所向而行。礙步的石頭，刺腳的荊棘，陷人的泥澤，溺人的水窪，所有一切前進的阻礙和危險，在這黑暗統治之下，一切被黑暗所同化；他倆也就不感到阻礙的艱難，不懷著危險的恐懼，相忘於黑暗之中；前進！行行前進，遂亦不受到阻礙，不遇著危險，前進！向著面前不知終極的路上，不停地前進。

　　在他倆自始就無有要遵著「人類曾經行過之跡」的念頭。在這黑暗之中，竟也沒有行不前進的事，雖遇有些顛蹶，也不能擋止他倆的前進。前進！忘了一切危險而前進。

　　在這樣黑暗之下，所有一切，盡攝伏在死一般的寂滅裡，只有風先生的慇懃，雨太太的好意，特別為他倆合奏著進行曲；只有這樂聲在這黑暗中歌唱著，要以慰安他倆途中的寂寞，慰勞他倆長行的疲憊。當樂聲低緩幽抑的時，宛然行於清麗的山徑，聽到泉聲和松籟的奏彈；到激昂緊張起來，又恍惚坐在卸帆的舟中，任被狂濤怒波所顛簸，是一曲極盡悲壯的進行曲，他倆雖沁漫在這樣樂聲之中，卻不能稍超興奮，併也不見陶醉，依然步伐整齊地前進，互相提攜走向前去。

　　不知行有多少時刻，經過幾許途程，忽從風雨合奏的進行曲中，分辨出浩蕩的溪聲。澎澎湃湃如幾千萬顆殞石由空中瀉下。這澎湃聲中，不知流失多少人類所託命的田，不知喪葬幾許為人類服務的黑骨頭；但是在黑暗裡，水面的夜光菌也放射不出光明來，溪的廣闊，不知橫亙到何處。

　　他倆只有前進的衝動催迫著，忘卻了溪和水，忘卻了一切。他們倆不是「先知」，在這時候眼睛也不能遂其效用。但是他倆竟會自己走到橋上，這在他們自己一點也沒有意識到，只當是前進中一程必經之路，他倆本無分別所行，是道路或非道路，是陸地或溪橋的意志，前進！只有前進，所以也不擔心到，橋梁是否有斷折，橋柱是否有傾斜，不股慄不內怯，泰然前進，互相提攜而前進，終也渡過彼岸。

　　前進！前進！他倆不想到休息，但是在他們發達未完成的肉體上，自然沒有這樣力量──現在的人類，還是孱弱的可憐，生理的作用在一程度以外，這不能用意志去抵抗去克制。──他倆疲倦了，思想也漸糢糊起來，筋骨已不接受腦的命令，體軀支持不住了，便以身體的重力倒下去，雖然他倆猶未忘記了前進，依然向著夢之國的路，繼續他們的行程。這時候風雨也停止進行曲的合奏，黑暗的氣氛愈加濃厚起來，把他倆埋沒在可怕的黑暗之下。

　　時間的進行，因為空間的黑暗，似也有稍遲緩，經過了很久，纔見有些白光，已像將到黎明之前。他倆人中的一個，不知是兄哥或小弟，身量雖然較高，筋肉比較的瘦弱，似是受到較多的勞苦的一人，想因為在夢之國的遊行，得了新的刺激，又產生有可供消費的勢力，再回到現實世界，便把眼皮睜開。──因為久慣於暗黑的眼睛，將要失去明視的效力，驟然受到光的刺激，忽起眩暈，非意識地復閉上了眼皮；一瞬之後，覺到大自然已盡改觀，已經看見圓圓的地平線，也分得出處處瀦留的水光，也看得見濃墨一樣高低的樹林，尤其使他喜極而起舞的，是為隱約地認出前進的路痕。

　　他不自禁地踴躍地走向前去，忘記他的伴侶，走過了一段里程，想因為腳有些疲軟，也因為地面的崎嶇，忽然地顛蹶，險些兒跌倒。此刻，他纔感覺到自己是在孤獨地前進，失了以前互相扶倚的伴侶，蔥惶回顧，看見映在地上自己的影，以為是他的同伴跟在後頭，他就發出歡喜的呼喊，趕快！光明已在前頭，跟來！趕快！

　　這幾聲呼喊，揭破死一般的重幕，音響的餘波，放射到地平線以外，掀動了靜止暗黑的氣氛，風雨又調和著節奏，奏起悲壯的進行曲。他的伴侶，猶在戀著夢之國的快樂，讓他獨自一個，行向不知終極的道上。暗黑的氣氛，被風的歌唱所鼓勵，又復濃濃密密屯集起來，眩眼一縷的光明，漸被遮蔽，空間又再恢復到前一樣的暗黑，而且有漸次濃厚的預示。

　　失了伴侶的他，孤獨地在黑暗中繼續著前進。

　　前進！向著那不知到著處的道上。……

# 南國哀歌/賴和

所有的戰士已都死去，
只殘存些婦女小兒，
這天大的奇變，
誰敢說是起於一時？
人們最珍重莫如生命，
未嘗有人敢自看輕，
這一舉會使種族滅亡，
在他們當然早就看明，
但終於覺悟地走向滅亡，
這原因就不容妄測。
雖說他們野蠻無知？
看見鮮紅的血，
便忘卻一切歡躍狂喜，
但是這一番啊！
明明和往日出草有異。
在和他們同一境遇，
一樣呻吟於不幸的人們，
那些怕死偷生的一群，
在這次血祭壇上，
意外地竟得生存，
便說這卑怯的生命，
神所厭棄本無價值。
但誰敢信這事實裡面，
就尋不出別的原因？
「一樣是歹命人！
趕快走下山去！」
這是什麼言語？
這有什麼含義？
這是如何地悲悽！
這是如何的決意！
是怨是讎？雖則不知，
是妄是愚？何須非議。
舉一族自愿同赴滅亡，
到最後亦無一人降志，
敢因為蠻性的遺留？
是怎樣生竟不如其死？
恍惚有這呼聲，這呼聲，
在無限空間發生響應，
一絲絲涼爽秋風，
忽又急疾地為它傳播，
好久已無聲響的雷，
也自隆隆地替它號令。
兄弟們！來--來！
來和他們一拚！
憑我們有這一身，
我們有這雙腕，
休怕他毒氣、機關鎗！
休怕他飛機、爆裂彈！
來！和他們一拚！
兄弟們！
憑這一身！
憑這雙腕！
兄弟們到這樣時候，
還有我們生的樂趣？
生的糧食儘管豐富，
容得我們自由獵取？
已闢農場已築家室，
容得我們耕種居住？
刀鎗是生活上必需的器具，
現在我們有取得的自由無？
勞動總說是神聖之事，
就是牛也只能這樣驅使，
任打任踢也只自忍痛，
看我們現在，比狗還輸！
我們婦女竟是消遣品，
隨他們任意侮弄蹂躪！
那一個兒童不天真可愛，
凶惡的他們忍相虐待，
數一數我們所受痛苦，
誰都會感到無限悲哀！
兄弟們來！
來！捨此一身和他一拚！
我們處在這樣環境，
只是偷生有什麼路用
眼前的幸福雖享不到，
也須為著子孫鬥爭。

# 忘不了的過年/賴和

小子不長進，平生慣愛咬文嚼字，「立名最小是文章」，「聲名不幸以詩傳」，這是多麼感慨的話啊！所以不願意側身所謂斯文之列──其實也不能夠──但在不知不覺的中間，也染些牢騷的皮氣（脾氣），偷得空間，便就學起病者痛苦的哀號，呻呻吟吟，自鳴得意，以樂其心志，和其哀情，不顧慮傍人，所謂風家也者，笑掉了齒牙，生性如此，雖用巨磨磨碎了此五尺之軀，使成粉末，乃和以森羅殿的還形復體水，再捏成一個未來生的我，怕也改不脫這個根性。現在只有覺悟，覺悟把臉皮張緊一些，任便人家笑罵，不教臉紅而已。

　　「光陰如矢」，這一句千古名言，我近來纔漸漸覺得它的意義，因為番仔過年（新曆新年）看看又要到了。可恨可咒詛的世界人類，尤其是那隆鼻碧瞳的紅毛番，美惡竟不會分別，有最古的文明，禮義之邦的中國，自很古就有完美的曆法，他們偏不採用，反採用那四季不調和，日月不相望的什麼新曆法，使得我們也不能不跟他多一次麻煩。但這是所謂大勢，說是沒有法子的事，除廢掉舊曆，奉行正朔，和他們做新過年。唉！這是多麼傷心的事啊！

　　在我未曾學過遊歷、視察、觀光的人，別地方是什麼樣子，我不明白，只在我們貴地，一到過年，不論什麼階級的人，精神上多有些緊張，行動上也有些忙碌，有的人，多半是閒著享福的人，和純真的孩童們，總在等待過年的快樂，但在手面趁吃人，不能不倍加他的工作，預備些新正年頭無工可做時的糧食，做事業的人們，也要計算他一年的成績，用以決定後來的經營方針，農民播種犁田，要趁節氣，猶不能放他們一刻空閒，就是那些文人韻士，也在腹中起草他「願與梅花共自新」一類的試筆詩，頂可憐的就是女人家了，過年種種的預備，務使春風吹來，家門有興騰的氣象，且新正閒著的時候，自己一身也不容不修飾，對男人怕失了他的玩愛，對同伴們要顯示她得到男人的憐惜。所以家裡市上，多亂惱惱地熱鬧著，新聞雜誌也各增刊而特刊，小子也乘這機會寫出這篇亂七倒八的文字。

　　究竟為的是什麼，何以故過年就要如此呢？新年的一日，和別的其餘的一日，也不是依然一日嗎？人們怎地在心境上，就有這樣的不同？唉！春五正月，這不是和舊時代的天子，與小百姓的關係一樣？

　　　　………………

　　什麼就是一年？天文學者的解釋說：「地球繞著太陽，運行了一個週環。」這是經過科學的證明，沒有錯誤的確定事實。

　　但現在的曆法，在我的知識程度裡，曉得有回、中、西三種，尚有住在山內那些我們的地主，也有他們一種曆，這說是野蠻的慣習，人們不預承認，在他們社會裡，卻自奉行唯謹。現在只就所謂有相當文化的根據，那三種曆法，略一對比，就使我發生了許多疑問，因為所規定的過年，完全不同日子，同在這顆地球上，地球也規矩地循著唯一的軌道，輾轉運行，怎地所說的一週會不同？若說因所認定的起始點，互有參差，故過年的規定遂各不同，那末地球運行最初，由何處開始？這一點不能明白，就可自由假設嗎？我要替地球提出抗議哩。

　　且中曆我也在書本上，看見有幾次的變遷，什麼建子、建丑、建寅，一年的設定，原無有確實的根據標準，不過隨意做作而已，也不是什麼大不了的事，何故世上的人類們，對著它有這麼大的感情？試把這箇假定廢掉，使人們沒有年歲的感覺，不是一件很合理得快活的事嗎？沒有年歲，不見得人們就活不下去，何用自作麻煩。

　　在幾千年前，當科白尼還未出世，大家猶信奉天圓地方，日月星辰是天空的附屬物的時代，日頭是自東徂西，自然不曉得地球是遵著軌道，在環繞太陽運轉，那時代的一年，以什麼為標準？天體的現象嗎，用什麼做根據？唉！這指定一箇日子為過年，和由無量數的人類中，教幾個人去做官一樣，終是不可解的疑問。

　　　　………………

　　一到過年，第一浮上我的思想，就是金錢。在我回憶裡，所能喚起的兒童時代，僅七、八歲時的狀況，在以前任怎地追憶，也只有朦朧一箇暗影而已。我在兒童時代，所以喜歡過年的來到，也因為能得到較多的金錢，可以借它的魔力，來增強我快樂的濃度。過年，在家裡有壓歲錢的分賜，由祖父母、爹媽、叔嬸，啊！手一插進衣袋，不用摸索，就可觸到金錢，唉！那時的快樂真有…但心還未足，有時再往親戚家去，借著拜年的名目，騙些「掛頷錢」（註一），親戚們多贊稱我，說我乖巧識禮，因為這是親戚間，一箇來往的禮節，不曉得我的目的，是在「掛頷錢」，人們又在禮讚兒童的天真聖潔。唉！禮這一字是很可利用的東西，不曉得誰創造的，我要頂禮他啊！

　　現在的我，是社會的一成員，人類的一分子了。快樂的追求，金錢的慾念，比較兒童時代，強盛到肉體的增長，多有一百倍以上。一到過年，金錢的問題，也就分外著急，愈著急愈覺得金錢的寶貴，愈覺得金錢的寶貴，金錢愈不能到手，也就為痛苦所脅迫了。又有不可得的快樂，在一邊誘惑我，那痛苦就更難堪了。我向來以為賺錢不是難事，「春錢」（剩錢）那更不成問題，若會賺錢，怕他不「春」？有「春」錢立地就成富豪勢力家，也就可以得到百般的快樂。現在可把我以前的思想，完全打消了，愈會賺錢，愈覺用錢的事故愈多，「春」錢的可能性愈少，富豪是先天所賦與，不是寒酸相的人可以昇格充數。愈要追尋快樂，愈會碰著痛苦。唉！

　　統我的一生──到現在，完全被過年和金錢所捉弄，大概到我生的末日也還是這樣罷。思想中只感覺年歲的川流，不斷地逝去，夢寐中也只見得金錢的寶光，在閃爍地放亮。既不能把它倆，由我的生的行程中，將腦髓裡驅逐，只有乘這履端初吉，捧出滿腔誠意，拜倒在歲星和財神寶座之下而已。

　　　　　一寸光陰一寸金，

　　　　　 黃金難買少年心。

　　　　　少年已去金難得，

　　　　　………………。

#鬥鬧熱/賴和

 拭過似的、萬里澄碧的天空，抹著一縷兩縷白雲，覺得分外悠遠，一顆銀亮亮的月球，由深藍色的山頭，不聲不響地，滾到了天半，把她清冷冷的光輝，包圍住這人世間，市街上罩著薄薄的寒煙，店舖簷前的天燈，和電柱上路燈，通溶化在月光裡，寒星似的一點點閃爍著。在冷靜的街尾，悠揚地幾聲洞簫，由著裊裊的晚風，傳播到廣大空間去，似報知人們，今夜是明月的良宵。這時候街上的男人們，似皆出門去了，只些婦女們，這邊門口幾人，那邊亭仔腳幾人，團團地坐著，不知談論些什麼，各個兒指手畫腳，說得很高興似的。

　　有一陣孩子們，哈哈笑笑弄著一條香龍，由隘巷中走出來，繞著亭仔腳柱，繞來穿去。

　　「厭人，」一婦人說，「到大街上玩去罷，那邊比較鬧熱。」

　　孩子們得到指示，嬉嬉譁譁地跑去了。

「等一會，」一個較大的孩子說，「我去拿一面鑼來。」

　　「好，很好，快來，趕快。」孩子們雀躍地催促著說。

　　快快快快（鑼的響聲，不知有什麼適當的字），銅鑼響亮地敲起來，「到城裡去啊！」有的孩子喊著，「好啊，去啊！」「來來！」一陣吶喊的聲浪，把孩子們和一條香龍，捲下中街去。

　　過了些時，孩子們垂頭喪氣跑回來，草繩上插的香條，拔去了不少，已不成一條龍的樣子，鑼聲亦不響了，有的孩子不平地在罵著叫喊著。

「鬧出什麼事來？」有些多事的人問。

　　「被他們欺負了，他媽的！」孩子們回答著，接著又說，「把我們龍頭割去！」

　　「汝們吵鬧過人家罷？」有人詰責似的問。

「沒有！我們是在空地上，」孩子們辯說，「又受了他們一頓罵！」

　　「那邊有些人，本來是橫逆不過的。」又一人說。

「蹧躂人！」又有人不平地說，「不可讓他佔便宜。」

　　「孩子們的事，管他做甚？」有人又不相關的說──一時議論沸騰起來，街上頓添一種活氣，有人說：「十五年前的熱鬧，怕大家都記不起了，再鬧一回亦好。」有人說：「要命，鬧起來怕就不容易息事。」──明月已漸漸斜向西去，籠罩著街上的煙，濛迷地濃結起來，燈火星星地，在冷風中戰慄著，街上佈滿著倦態和睡容，一綵綵霜痕，透過了衣衫，觸進人們的肌膚，在成堆的人們中，多有了袖著手、縮著頸、聳著肩、伸著腰、打呵欠的樣子。議論已失去了熱烈，因為寒冷和睡眠的催促，雖未見到結論，人們也就三三五五的散去。

　　隔晚，那邊也有一陣孩子們的行列，鬧過別一邊去，居然宣佈了戰爭，接連鬥過兩三晚，已經因「囝仔事惹起大人代」。

　　一晚上，一邊的行列，被另一邊阻撓著，因一邊還都屬孩子，擋不住大的拳頭，雖受過欺負，只有含恨地隱忍而已。──像這樣子鬧下去，保不定不鬧出事來，遂有人出來阻擋，鬧熱也就沒得結局了。

　　一邊就以為得到了勝利──在優勝者的地位，本來有任意凌辱壓迫劣敗者權柄。所以他們不敢把這沒出處的威權，輕輕放棄，也就忠實地行使起來。可不知道那就是培養反抗心的源泉，導發反抗力的火戰。一邊有些氣憤不過的人，就不能再忍住下去了。約同不平者的聲援，所謂雪恥的競爭，就再開始。──一邊，是抱著滿腹的憤氣，一邊，是「儉腸捏肚也要壓倒四福戶」（諺語）的子孫，遺傳著有好勝的氣質。所以這一回，就鬧得非同小狗（瘋狗）了。但無錢本來是做不成事，就有人出來奔走勸募。雖亦有人反對，無奈群眾的心裡，熱血正在沸騰，一勺冰水，不是容易就能奏功，各要爭個體面，所有無謂的損失，已無暇計較。一夜的花費，將要千圓。又因接近街的繁榮日，一時看鬧熱的人，四方雲集，果然市況一天繁榮似一天。

　　在一處的客廳裡，有好些個等著看鬧熱的人，坐著閒談。

　　「唉！我記得還似昨天，」甲微喟的說，「怎麼就十五年了。」

　　「歲月真容易過！」乙感嘆地說，「那時代的頭老醉舍（頭老，地方領導人。舍，對搢紳子弟或有錢人的尊稱。），已經財散人亡，現在想沒得再一個，天天花費三兩百圓不要緊的。」

　　「實在是無意義的競爭，」丙喝一喝茶，放下茶杯，慢慢地說，「在這時候，救死且沒有工夫，還有閒時間，來浪費有用的金錢，實在可憐可恨，究竟爭得是什麼體面？」

　　「樹要樹皮人要麵皮，」甲興奮地說，「誰甘白受人家的欺負，不要爭一爭氣，甘失掉了麵皮！」

　　「什麼是麵皮？」丙論辯似的說，「還有被人家欺辱得不堪的，卻自甘心著，連哼的一聲亦不敢，說什麼爭氣，孩子般的眼光，值得說什麼爭麵皮！」

　 「現時可說比較好些兒，」一個有年紀的人，阻斷爭論，經驗過似的鄭重說，「像日本未來的時，四城門的競爭，那纔利害啦！」

　　「什麼樣子，那時候？」一個年輕的稀奇地問。

　　「唉！」老人感慨地說，「那時代，地方自治的權能，不像現時剝奪得淨盡，握著有很大權威，住在福戶內的人，不問是誰，福戶內的事，誰都有義務分擔，有什麼科派捐募，是不容有異議，要是說一聲不肯，那就刻不能住這福戶內，所以窮的人，典衫當被，也要來和人家爭這不關什麼的臉皮。」

　　「聽說有一樁可憐可笑的，」乙接著嘴說，「西門那賣點心的老人，五十塊的老本（終老喪費）和一圈豚，連生意本，全數花掉，還再受過全街的嘲笑。」

　　「實在也就難怪，」甲吐出那飽吸過的香煙，在煙縷繚繞的中間，張開他得意的大口，「前回不是因得到勝利（他一人的批判），所以那邊的街市，就發達繁昌起來，某某和某等，不是皆發了幾十萬，真所謂狗屎埔變成狀元地。」

　　「就說不關什麼，」一位像有學識的人說，「也是生活上一種餘興，像某人那樣出氣力的反對，本該挨罵。不曉得順這機會，正可養成競爭心，和鍛鍊團結力。」

　　「這回在奔走的人，」乙說，「不是有學士有委員，中等學校卒業生和保正，不是皆有學問有地位的人士，他偏說這是無知的人所做的野蠻舉行，要賣弄他自己的聰明。」

　　「他說人們是在發狂，他正在發瘋呢。」甲哈哈地笑著說。

「聽說市長和郡長，都很讚成，」乙說，「昨晚曾賜過觀覽，在市政廳前和郡衙前，放不少鞭炮，在表示著歡迎。」

　　「那末汝以為就是無上光榮了？」丙可憐似的說。

　　「能夠合官廳的意思，那就....。」甲說，「他媽的，看他有多大力量能夠反對！」

　　「聽說有人在講和，可能成功嗎？」老人懷疑地問。

　　「他媽的，」甲憤憤地罵，「花各人自己的錢，他不和人家分擔，不趕他出去，也就便宜，要硬來阻礙別人的興頭，他媽的！」

　　「明夜沒得再看啦！」纔進屋子來的一個人說。

「什麼？」丙驚疑地問，「聽說因了某某的奔走，已不成功了，怎麼樣就講和？」

　　「人們多不自量，」進來的人說，「他叩了不少下頭，說了不少好話，總值不得市長一開口，他那麼盡力，不能成功，剛纔經市長一說，兩方就各答應了。」

　　「怎麼就這樣容易？」丙說，「實在想不到！」

　　「因為不高興了。」那人道，「在做頭老的，他高興的時候，就一味地吶喊著，現在不高興了，就和解去。」

　　「下半天的談判，不是誰都很強硬嗎？」丙問。

　　「死鴨子的嘴吧，」那人說，「現在小戶已負擔不起，要用到他們頭老的錢了。還有不講和的？」

　　「早幾點鐘解決，」乙說，「一邊就可省節六、七百塊，聽說路關鐘鼓，已經準備下，這一筆錢就白花的啦！」

　　「我的意見，」丙說，「那些富家人，花去了幾千塊，是算不上什麼。他們在平時，要損他一文，也是不容易，再鬧下去，使勞者們，多得一回賣力的機會，亦不算壞。」

　　「汝算不到，」老人說，「抵當賓客的使費，在貧家，也就不容易，一塊錢，現在不是糴不到半斗米？」

　　「他媽的，老不死的混蛋！」甲總不平地罵。

　　鬧熱到了，街上的孩子們在喊。這些談論的人，先先後後，亦都出去了，屋裡頭只留著茶杯、茶瓶、煙草、火柴在批評這一回事，街上看鬧熱的人，波湧似的，一層層堆聚起來。

　　翌日，街上還是鬧熱，因為市街的鬧熱日，就在明后兩天。──人們的信仰，媽祖的靈應，是策略中必需的要件；神輿的繞境，旗鼓的行列，是繁榮上頂要的工具──真的到那兩天，街上實在繁榮極了。第三天那些遠來的人們，不能隨即回家，所以街上還見得鬧熱，一到夜裡，在新月微光下的街市，只見道路上映著剪伐過的疏疏樹影，還聽得到幾聲行人的咳嗽，和狺狺的狗吠，很使人戀慕著前天的鬧熱。
