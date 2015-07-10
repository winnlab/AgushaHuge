moment = require 'moment'
mongoose = require 'mongoose'
mongoosePages = require 'mongoose-pages'
translit = require 'transliteration.cyr'

ObjectId = mongoose.Schema.Types.ObjectId

cropperPosition =
  x:
    type: Number
  y:
    type: Number
  width:
    type: Number
  height:
    type: Number
  alt:
    type: Boolean

schema = new mongoose.Schema
  type:
    name:
      type: String
      required: true
      index: true
  updated:
    type: Date
    required: true
    default: moment
  created:
    type: Date
    required: true
    default: -> moment().format()
    set: (date) -> moment(date, 'DD/MM/YYYY').format()
  title:
    type: String
    required: true
    index: 'text'
  transliterated:
    type: String
    unique: true
  desc:
    shorttext:
      type: String
    text:
      type: String
      index: 'text'
    images: [
      type: String
    ]
  image:
    background:
      type: String
    backgroundAlt:
      type: String
    B:
      type: String
    S:
      type: String
    L:
      type: String
    XL:
      type: String
    SOCIAL:
      type: String
    dataB: cropperPosition
    dataS: cropperPosition
    dataL: cropperPosition
    dataXL: cropperPosition
    dataSOCIAL: cropperPosition
  active:
    type: Boolean
    required: true
    default: true
  recommended:
    type: Boolean
    required: true
    default: false
  hideOnMain:
    type: Boolean
    required: true
    default: false
  position:
    type: Number
    unique: true
    index: true
  hasBigView:
    type: Boolean
    default: false
  hasVideo:
    type: Boolean
    default: false
  videoUrl:
    type: String
  age: [
    _id:
      type: ObjectId
      ref: "Age"
      set: mongoose.Types.ObjectId
      sparse: true
    title:
      type: String
    fixture:
      type: String
  ]
  theme: [
    _id:
      type: ObjectId
      ref: "Theme"
      set: mongoose.Types.ObjectId
      sparse: true
    name:
      type: String
    position:
      type: Number
      sparse: true
    hasBigView:
      type: Boolean
      default: false
  ]
  likes: [
    client:
      type: ObjectId
      ref: 'Client'
  ]
  commentaries: [
    client:
      client_id:
        type: ObjectId
        ref: 'Client'
      profile:
        type: Object
        default: {}
      image:
        type: String

    content:
      type: String
      default: ''
    date:
      type: Date
      required: true
      default: moment
    image:
      type: String
      default: ''
    rating: [
      client:
        type: ObjectId
        ref: 'Client'
      value:
        type: Number
    ]
    scoreInc:
      type: Number
      default: 0
    scoreDec:
      type: Number
      default: 0
  ]
  is_quiz:
    type: Boolean
    default: false
  answer: [
    _id:
      type: ObjectId
      default: mongoose.Types.ObjectId
    text:
      type: String
    position:
      type: Number
    clients: [
      client:
        type: ObjectId
        ref: 'Client'
    ]
  ]
  counter:
    like:
      type: Number
      default: 0
    comment:
      type: Number
      default: 0
    view:
      type: Number
      default: 0
    answer:
      type: Number
      default: 0
  meta:
    title:
      type: String
    desc:
      type: String
    keywords:
      type: String
,
  collection: 'news'

schema.methods.name = -> @title

schema.pre 'save', (next) ->
  this.updated = moment()
  this.transliterated = translit
    .transliterate this.title
    .replace /\s/g, '_'
    .replace /[^\w\d_]/g, ''

  next()

mongoosePages.anchor schema

module.exports = mongoose.model 'News', schema