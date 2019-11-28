function interactive(state, silent) {
  var attrs, content, embedFlag, labelEnd, labelStart, max, pos, start, token, vCharCode;
  max = state.posMax;
  pos = state.pos;
  vCharCode = state.src.charCodeAt(pos);
  if ((vCharCode !== 0x21 || state.src.charCodeAt(pos + 1) !== 0x5B) && vCharCode !== 0x5B) {
    return false;
  }
  if (vCharCode === 0x21) {
    labelStart = pos + 2;
    embedFlag = true;
    pos++;
  } else {
    labelStart = pos + 1;
    embedFlag = false;
  }
  labelEnd = state.md.helpers.parseLinkLabel(state, pos, true);
  if (labelEnd < 0) {
    return false;
  }
  pos = labelEnd + 1;
  if (pos < max && state.src.charCodeAt(pos) !== 0x7B) {
    return false;
  }
  start = pos;
  while (pos < max) {
    vCharCode = state.src.charCodeAt(pos);
    if (vCharCode === 0x0A || vCharCode === 0x7D) {
      break;
    }
    pos++;
  }
  if (vCharCode !== 0x7D) {
    return false;
  }
  content = state.src.slice(start + 1, pos);
  if (!silent) {
    state.pos = labelStart;
    state.posMax = labelEnd;
    token = state.push('ivar_open', 'span', 1);
    token.attrs = attrs = [['class', 'AMElement'], ['data-embed', embedFlag], ['data-config', content]];
    state.md.inline.tokenize(state);
    token = state.push('ivar_close', 'span', -1);
  }
  state.pos = pos + 1;
  state.posMax = max;
  return true;
};

module.exports = function(md) {
  console.log('iiiiiiiiiiiiiiiiiiii')
  return md.inline.ruler.after('emphasis', 'interactive', interactive);
};

