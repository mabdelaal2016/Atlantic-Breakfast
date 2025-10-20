
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

// ===== i18n =====
class I18n extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isAr => _locale.languageCode=='ar';
  TextDirection get dir => isAr ? TextDirection.rtl : TextDirection.ltr;
  void setLocale(Locale l){ _locale = l; notifyListeners(); }
  String t(String k)=>_t[_locale.languageCode]?[k]??k;
  static const _t = {
    'ar': {
      'app':'Atlantic Breakfast','lang_ar':'عربي','lang_en':'English',
      'login_title':'مرحبًا — ادخل لطلب فطورك بسرعة','name':'الاسم','mobile':'رقم الموبايل','dept':'القسم',
      'remember':'تذكرني للدخول تلقائيًا','go_menu':'دخول إلى المنيو',
      'menu':'المنيو','add':'أضف','cart':'العربة','empty':'العربة فارغة',
      'total':'الإجمالي','send':'إرسال الطلب','choose_payment':'اختر طريقة الدفع',
      'cash':'نقدًا','insta':'إنستا باي','insta_num':'رقم إنستا باي: 01272716001',
      'done_cash':'تم إرسال طلبك وسيتم الدفع عند الاستلام ✅',
      'done_insta':'تم إرسال طلبك — برجاء التحويل عبر إنستا باي ✅',
      'summary':'ملخص الطلب','back_menu':'رجوع للمنيو','sign_out':'تسجيل خروج',
      'hello':'أهلًا','dept_word':'قسم','mobile_word':'موبايل','empty_cart':'تفريغ العربة',
      'admin_login':'دخول الإدارة','username':'اسم المستخدم','password':'كلمة السر','login':'دخول','cancel':'إلغاء',
      'orders':'لوحة الطلبات','status':'الحالة','new':'جديد','preparing':'تحت التجهيز','delivered':'تم التسليم','canceled':'تم الإلغاء',
      'items':'تفاصيل الطلب','payment':'الدفع','time':'الوقت','action':'إجراء','other':'Other…','add_to_list':'إضافة للقائمة',
      'name_required':'أدخل الاسم والموبايل والقسم',
      'credits':'Application developed by Mohamed Ibrahim • Department: Drawback'
    },
    'en': {
      'app':'Atlantic Breakfast','lang_ar':'Arabic','lang_en':'English',
      'login_title':'Welcome — Order your breakfast quickly','name':'Name','mobile':'Mobile','dept':'Department',
      'remember':'Remember me for next time','go_menu':'Go to Menu',
      'menu':'Menu','add':'Add','cart':'Cart','empty':'Cart is empty',
      'total':'Total','send':'Send Order','choose_payment':'Choose payment method',
      'cash':'Cash','insta':'InstaPay','insta_num':'InstaPay: 01272716001',
      'done_cash':'Order sent — Cash on delivery ✅',
      'done_insta':'Order sent — Please transfer via InstaPay ✅',
      'summary':'Summary','back_menu':'Back to Menu','sign_out':'Sign out',
      'hello':'Hello','dept_word':'Dept','mobile_word':'Mobile','empty_cart':'Empty cart',
      'admin_login':'Admin Login','username':'Username','password':'Password','login':'Login','cancel':'Cancel',
      'orders':'Orders Dashboard','status':'Status','new':'New','preparing':'Preparing','delivered':'Delivered','canceled':'Canceled',
      'items':'Items','payment':'Payment','time':'Time','action':'Action','other':'Other…','add_to_list':'Add to list',
      'name_required':'Enter name, mobile and department',
      'credits':'Application developed by Mohamed Ibrahim • Department: Drawback'
    },
  };
}

// ===== Models & State =====
class MenuItem { final String id; final String ar; final String en; final double price; const MenuItem(this.id,this.ar,this.en,this.price); }
class OrderItem { final MenuItem item; int qty; OrderItem(this.item,[this.qty=1]); Map<String,dynamic> toJson()=>{'id':item.id,'ar':item.ar,'en':item.en,'price':item.price,'qty':qty}; }
class Order { final String id,name,mobile,dept,payment; final DateTime at; final List<OrderItem> items; String status;
  Order({required this.id,required this.name,required this.mobile,required this.dept,required this.payment,required this.at,required this.items,this.status='pending'});
  double get total=>items.fold(0,(s,e)=>s+e.item.price*e.qty);
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'mobile':mobile,'dept':dept,'payment':payment,'at':at.toIso8601String(),'status':status,'items':items.map((e)=>e.toJson()).toList()};
}
class AppState extends ChangeNotifier{
  final menu = const [
    MenuItem('m1','فول بالفلفل','Foul with Pepper',7.5),
    MenuItem('m2','فول سادة','Foul Plain',7.5),
    MenuItem('m3','بطاطس','Potatoes',7.5),
    MenuItem('m4','طعميه','Falafel',7.5),
    MenuItem('m5','بطاطس بالبيض','Potatoes with Eggs',13.5),
    MenuItem('m6','٢ بيضة + خبز','2 Eggs with Bread',13.5),
  ];
  final defaultDepts=['Management','Finance','Accounting','IT','HR','Marketing','Sales','Customer Service','Logistics','Procurement','Operations','Production','Quality','Maintenance','Warehouse','Security','Reception','Projects','Engineering','R&D','Administration'];
  String name='', mobile='', dept=''; bool remember=false;
  List<String> depts=[]; List<OrderItem> cart=[]; List<Order> orders=[];
  Future<void> load()async{final sp=await SharedPreferences.getInstance(); depts=sp.getStringList('depts')??defaultDepts; name=sp.getString('name')??''; mobile=sp.getString('mobile')??''; dept=sp.getString('dept')??(depts.isNotEmpty?depts.first:''); remember=sp.getBool('remember')??false;
    final s=sp.getString('orders'); if(s!=None and s!=null){final l=(jsonDecode(s) as List).cast<Map<String,dynamic>>(); orders=l.map((o){final items=(o['items'] as List).map((i)=>OrderItem(menu.firstWhere((m)=>m.id==i['id'], orElse:()=>MenuItem(i['id'],i['ar'],i['en'],(i['price'] as num).toDouble())), i['qty'])).toList(); return Order(id:o['id'],name:o['name'],mobile:o['mobile'],dept:o['dept'],payment:o['payment'],at:DateTime.parse(o['at']),items:items,status:o['status']);}).toList();}
    notifyListeners();}
  Future<void> saveProfile()async{final sp=await SharedPreferences.getInstance(); if(remember){sp.setString('name',name);sp.setString('mobile',mobile);sp.setString('dept',dept);} else {sp.remove('name');sp.remove('mobile');sp.remove('dept');} sp.setBool('remember',remember);}
  Future<void> saveDepts()async{final sp=await SharedPreferences.getInstance(); sp.setStringList('depts',depts);}
  Future<void> saveOrders()async{final sp=await SharedPreferences.getInstance(); sp.setString('orders',jsonEncode(orders.map((e)=>e.toJson()).toList()));}
  void add(MenuItem it){final i=cart.indexWhere((e)=>e.item.id==it.id); if(i>=0) cart[i].qty++; else cart.add(OrderItem(it,1)); notifyListeners();}
  void inc(int i){cart[i].qty++; notifyListeners();} void dec(int i){cart[i].qty--; if(cart[i].qty<=0) cart.removeAt(i); notifyListeners();}
  void clear(){cart.clear(); notifyListeners();}
  double get total=>cart.fold(0,(s,e)=>s+e.item.price*e.qty);
  Future<Order> place(String pay)async{final o=Order(id:'ORD-${DateTime.now().millisecondsSinceEpoch}',name:name,mobile=mobile,dept=dept,payment=pay,at:DateTime.now(),items:cart.map((e)=>OrderItem(e.item,e.qty)).toList()); orders.insert(0,o); await saveOrders(); clear(); return o;}
  Future<void> setStatus(Order o,String s)async{o.status=s; await saveOrders(); notifyListeners();}
}

// ===== UI =====
class MyApp extends StatelessWidget{ const MyApp({super.key});
  @override Widget build(BuildContext c){return MultiProvider(providers:[ChangeNotifierProvider(create:(_)=>I18n()),ChangeNotifierProvider(create:(_)=>AppState()..load())], child: Consumer<I18n>(builder:(_,i,__)=>MaterialApp(title:i.t('app'),debugShowCheckedModeBanner:false, locale:i.locale, home:Root(), builder:(c,w)=>Directionality(textDirection:i.dir, child:w!))));}}

class Root extends StatefulWidget{ @override State<Root> createState()=>_R();}
class _R extends State<Root>{int page=0; Order? last;
  @override Widget build(BuildContext c){
    final i= c.watch<I18n>(); return Scaffold(appBar: AppBar(title: Text(i.t('app')), actions:[TextButton(onPressed:()=>c.read<I18n>().setLocale(const Locale('ar')), child: Text(i.t('lang_ar'),style:const TextStyle(color:Colors.white))),TextButton(onPressed:()=>c.read<I18n>().setLocale(const Locale('en')), child: Text(i.t('lang_en'),style:const TextStyle(color:Colors.white))), TextButton(onPressed:(){setState(()=>page=3);}, child: Text(i.t('admin_login'),style:const TextStyle(color:Colors.white))),]), body: Padding(padding:const EdgeInsets.all(12), child: IndexedStack(index:page, children:[Login(onGo:(){setState(()=>page=1);}), Menu(onDone:(o){setState((){last=o; page=2;});}), Done(order:last, onBack:(){setState(()=>page=1);}, onOut:(){setState(()=>page=0);}), Admin() ])));}}

class Login extends StatefulWidget{final VoidCallback onGo; const Login({required this.onGo}); @override State<Login> createState()=>_L();}
class _L extends State<Login>{final n=TextEditingController(), m=TextEditingController(), newDept=TextEditingController(); String? d; bool rem=false;
  @override void initState(){super.initState(); final a=context.read<AppState>(); n.text=a.name; m.text=a.mobile; d=a.dept.isNotEmpty?a.dept:(a.depts.isNotEmpty?a.depts.first:null); rem=a.remember;}
  @override Widget build(BuildContext c){final i=c.watch<I18n>(); final a=c.watch<AppState>(); final depts=[...a.depts,'OTHER__'];
    return SingleChildScrollView(child: Card(child: Padding(padding:const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Center(child: Column(children:[Image.asset('assets/logo.png',height:64), const SizedBox(height:12), Text(i.t('login_title'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),])), const SizedBox(height:12),
      Row(children:[Expanded(child:_Lab(i.t('name'), TextField(controller:n))), const SizedBox(width:8), Expanded(child:_Lab(i.t('mobile'), TextField(controller:m, keyboardType: TextInputType.phone)))]),
      const SizedBox(height:8),
      _Lab(i.t('dept'), DropdownButtonFormField<String>(value:d, items:depts.map((x)=>DropdownMenuItem(value:x, child: Text(x=='OTHER__'? i.t('other'):x))).toList(), onChanged:(v){setState(()=>d=v);} )),
      if(d=='OTHER__')...{ const SizedBox(height:8), Row(children:[Expanded(child:_Lab(i.t('dept'), TextField(controller:newDept))), const SizedBox(width:8), ElevatedButton(onPressed:()async{final nd=newDept.text.trim(); if(nd.isEmpty)return; if(!a.depts.contains(nd)){a.depts=[...a.depts, nd]; await a.saveDepts();} setState(()=>d=nd); newDept.clear();}, child: Text(i.t('add_to_list')))])},
      const SizedBox(height:8), Row(children:[Checkbox(value:rem, onChanged:(v){setState(()=> rem=v??false);}), Text(i.t('remember'))]), const SizedBox(height:12),
      ElevatedButton(onPressed:()async{final nm=n.text.trim(), mb=m.text.trim(); final dp=(d=='OTHER__'? newDept.text.trim(): d)??''; if(nm.isEmpty||mb.isEmpty||dp.isEmpty){ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(i.t('name_required')))); return;} final a=context.read<AppState>(); a.name=nm;a.mobile=mb;a.dept=dp; a.remember=rem; await a.saveProfile(); widget.onGo();}, child: Text(i.t('go_menu'))),
      const SizedBox(height:12), Center(child: Text(i.t('credits'), style: const TextStyle(color: Colors.grey))), ])))) ;}
}

class Menu extends StatelessWidget{final Future<void> Function(Order) onDone; const Menu({required this.onDone});
  @override Widget build(BuildContext c){final i=c.watch<I18n>(); final a=c.watch<AppState>();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text('${i.t('hello')} ${a.name} — ${i.t('dept_word')} ${a.dept} — ${i.t('mobile_word')}: ${a.mobile}'),
        const SizedBox(height:8), Text(i.t('menu'), style: const TextStyle(fontSize:18,fontWeight:FontWeight.bold)), const SizedBox(height:8),
        Wrap(spacing:8,runSpacing:8, children: a.menu.map((m)=> Card(child: Container(width:200, padding:const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Container(height:90, alignment:Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors:[Color(0xfffef9c3), Color(0xfffff7ed)]), borderRadius: BorderRadius.circular(12)), child: const Text('AB', style: TextStyle(fontSize:28, fontWeight:FontWeight.bold, color: Color(0xff7c2d12)))),
          const SizedBox(height:8), Text(i.isAr? m.ar: m.en, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text('${m.price.toStringAsFixed(2)} EGP', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), ElevatedButton(onPressed: ()=> c.read<AppState>().add(m), child: Text(i.t('add'))), ]),
        ])), )).toList() ) ])),
      const SizedBox(width:12),
      SizedBox(width:320, child: Card(child: Padding(padding:const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(i.t('cart'), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
        if(a.cart.isEmpty) Text(i.t('empty')) else Column(children: List.generate(a.cart.length, (k){final cIt=a.cart[k]; return Container(margin: const EdgeInsets.only(bottom:8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
          Expanded(child: Text('${i.isAr? cIt.item.ar: cIt.item.en} × ${cIt.qty}')), Text('${(cIt.item.price*cIt.qty).toStringAsFixed(2)}'),
          Row(children:[ IconButton(onPressed: ()=> c.read<AppState>().dec(k), icon: const Icon(Icons.remove_circle_outline)), IconButton(onPressed: ()=> c.read<AppState>().inc(k), icon: const Icon(Icons.add_circle_outline)), IconButton(onPressed: ()=> c.read<AppState>().cart.removeAt(k), icon: const Icon(Icons.delete_outline, color: Colors.red)), ]),
        ])); })),
        const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text(i.t('total')), Text('${a.total.toStringAsFixed(2)} EGP', style: const TextStyle(fontWeight: FontWeight.bold)) ]),
        const SizedBox(height:8),
        ElevatedButton(onPressed: a.cart.isEmpty? null : () async { final pay = await showDialog<String>(context:c, builder:(ctx)=> AlertDialog(title: Text(i.t('choose_payment')), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[
          ElevatedButton(onPressed: ()=> Navigator.pop(ctx,'cash'), child: Text(i.t('cash'))), const SizedBox(height:6),
          ElevatedButton(onPressed: ()=> Navigator.pop(ctx,'insta'), child: Text(i.t('insta'))), const SizedBox(height:6), Text(i.t('insta_num'), style: const TextStyle(color: Colors.grey)), ]), actions:[ TextButton(onPressed: ()=> Navigator.pop(ctx), child: Text(i.t('cancel'))) ])); if(pay==null)return;
          final o = await c.read<AppState>().place(pay); await onDone(o); }, child: Text(i.t('send'))),
        const SizedBox(height:8),
        TextButton(onPressed: ()=> c.read<AppState>().clear(), child: Text(i.t('empty_cart'))),
      ])))),
    ]);
  }
}

class Done extends StatelessWidget{final Order? order; final VoidCallback onBack, onOut; const Done({required this.order, required this.onBack, required this.onOut});
  @override Widget build(BuildContext c){final i=c.watch<I18n>(); if(order==null) return const SizedBox(); final isCash=order!.payment=='cash';
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(isCash? i.t('done_cash'): i.t('done_insta'), style: const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      if(!isCash) Padding(padding: const EdgeInsets.only(top:8), child: Text(i.t('insta_num'), style: const TextStyle(color: Colors.grey))),
      const Divider(),
      Text(i.t('summary'), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:6),
      ...order!.items.map((it)=> Text('• ${(i.isAr? it.item.ar: it.item.en)} × ${it.qty} = ${(it.item.price*it.qty).toStringAsFixed(2)} EGP')),
      const SizedBox(height:8), Text('${i.t('total')}: ${order!.total.toStringAsFixed(2)} EGP', style: const TextStyle(fontWeight: FontWeight.bold)),
      const Divider(),
      Row(children:[ ElevatedButton(onPressed:onBack, child: Text(i.t('back_menu'))), const SizedBox(width:8), OutlinedButton(onPressed:onOut, child: Text(i.t('sign_out'))), ]),
    ])));}
}

class Admin extends StatefulWidget{ @override State<Admin> createState()=>_A();}
class _A extends State<Admin>{ bool logged=false; final u=TextEditingController(text:'admin'); final p=TextEditingController(text:'123456');
  @override Widget build(BuildContext c){final i=c.watch<I18n>(); final a=c.watch<AppState>();
    if(!logged){ return Center(child: Card(child: Padding(padding:const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children:[
      Text(i.t('admin_login'), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height:8),
      TextField(controller:u, decoration: InputDecoration(labelText:i.t('username'))),
      const SizedBox(height:6), TextField(controller:p, obscureText:true, decoration: InputDecoration(labelText:i.t('password'))),
      const SizedBox(height:10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children:[ ElevatedButton(onPressed:(){ if(u.text.trim()=='admin' && p.text.trim()=='123456') setState(()=>logged=true); else ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Wrong credentials'))); }, child: Text(i.t('login'))),
        const SizedBox(width:8), OutlinedButton(onPressed:(){u.clear();p.clear();}, child: Text(i.t('cancel'))), ]),
    ])) )); }
    final list=[...a.orders]..sort((a,b)=>b.at.compareTo(a.at));
    return SingleChildScrollView(child: Card(child: Padding(padding:const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(i.t('orders'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height:8),
      DataTable(columns:[ DataColumn(label: Text(i.t('name'))), DataColumn(label: Text(i.t('mobile'))), DataColumn(label: Text(i.t('dept'))), DataColumn(label: Text(i.t('items'))), DataColumn(label: Text(i.t('total'))), DataColumn(label: Text(i.t('time'))), DataColumn(label: Text(i.t('payment'))), DataColumn(label: Text(i.t('status'))), DataColumn(label: Text(i.t('action'))), ],
        rows: list.map((o){ final itemsTxt=o.items.map((i)=> (c.read<I18n>().isAr? i.item.ar: i.item.en)+' × '+i.qty.toString()).join(' ، ');
          return DataRow(cells:[ DataCell(Text(o.name)), DataCell(Text(o.mobile)), DataCell(Text(o.dept)), DataCell(SizedBox(width:220, child: Text(itemsTxt))), DataCell(Text(o.total.toStringAsFixed(2))), DataCell(Text(o.at.toLocal().toString().split('.').first)), DataCell(Text(o.payment=='insta'?'InstaPay':'Cash')), DataCell(Text(_st(c,o.status))), DataCell(Row(children:[ TextButton(onPressed:()=>c.read<AppState>().setStatus(o,'preparing'), child: Text(c.read<I18n>().t('preparing'))), TextButton(onPressed:()=>c.read<AppState>().setStatus(o,'delivered'), child: Text(c.read<I18n>().t('delivered'))), TextButton(onPressed:()=>c.read<AppState>().setStatus(o,'canceled'), child: Text(c.read<I18n>().t('canceled'), style: const TextStyle(color: Colors.red))), ])), ]); }).toList() ),
    ]))));
  }
  String _st(BuildContext c, String s){final i=c.read<I18n>(); switch(s){case 'pending': return i.t('new'); case 'preparing': return i.t('preparing'); case 'delivered': return i.t('delivered'); case 'canceled': return i.t('canceled'); default: return s;}}
}

class _Lab extends StatelessWidget{ final String l; final Widget w; const _Lab(this.l,this.w);
  @override Widget build(BuildContext c)=> Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(l, style: const TextStyle(color: Colors.grey)), const SizedBox(height:4), w ]);
}
